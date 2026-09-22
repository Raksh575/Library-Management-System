import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:http/http.dart' as http;

typedef VoidCallback = void Function();

class ChatbotPopup extends StatefulWidget {
  final VoidCallback onClose;
  const ChatbotPopup({super.key, required this.onClose});

  @override
  State<ChatbotPopup> createState() => _ChatbotPopupState();
}

class _ChatbotPopupState extends State<ChatbotPopup> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  // Popup size constants
  static const double popupWidth = 280;
  static const double popupHeight = 380;

  // Drag position offset
  Offset _position = Offset.zero;

  // Your Google Books API key
  static const String googleApiKey = '//place your apikey';

  @override
  void initState() {
    super.initState();
    // Initialize popup position after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      setState(() {
        _position = Offset(screenSize.width - popupWidth - 20, 150);
      });
    });
  }

  Future<String> fetchBookSummary(String query) async {
    final url =
        'https://www.googleapis.com/books/v1/volumes?q=${Uri.encodeComponent(query)}&key=$googleApiKey&maxResults=1';

    try {
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if ((data['totalItems'] ?? 0) > 0) {
          final book = data['items'][0]['volumeInfo'];
          String title = book['title'] ?? 'No Title';
          String authors = (book['authors'] != null)
              ? (book['authors'] as List).join(', ')
              : 'Unknown Author';
          String desc = book['description'] ?? 'No description available.';
          return "**$title** by $authors\n\n$desc";
        } else {
          return "No book found for \"$query\".";
        }
      } else {
        return "Error: ${resp.statusCode}";
      }
    } catch (e) {
      return "Error fetching summary: $e";
    }
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.insert(0, _ChatMessage(text: text, sender: Sender.user));
      _isLoading = true;
    });
    _controller.clear();

    final botResp = await fetchBookSummary(text);

    setState(() {
      _messages.insert(0, _ChatMessage(text: botResp, sender: Sender.bot));
      _isLoading = false;
    });
  }

  Widget _buildMessage(_ChatMessage msg) {
    bool isUser = msg.sender == Sender.user;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // Limit bubble width to avoid overflow
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: BubbleSpecialOne(
              text: msg.text,
              isSender: isUser,
              color: isUser ? Colors.indigo : Colors.grey[200]!,
              textStyle:
              TextStyle(color: isUser ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {},
      child: Stack(
        children: [
          Positioned(
            left: _position.dx,
            top: _position.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  double newX = _position.dx + details.delta.dx;
                  double newY = _position.dy + details.delta.dy;

                  newX = newX.clamp(0.0, screenSize.width - popupWidth);
                  newY = newY.clamp(0.0, screenSize.height - popupHeight);

                  _position = Offset(newX, newY);
                });
              },
              child: Material(
                elevation: 16,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: popupWidth,
                  height: popupHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Title bar
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: const BoxDecoration(
                          color: Colors.indigo,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              "Your Assistent",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: widget.onClose,
                              child: const Icon(Icons.close, color: Colors.white),
                            )
                          ],
                        ),
                      ),

                      // Chat area
                      Expanded(
                        child: _messages.isEmpty
                            ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Welcome to MCET Library Agent! Ask me about books…",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                        )
                            : ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.all(8),
                          itemCount: _messages.length,
                          itemBuilder: (context, idx) {
                            return _buildMessage(_messages[idx]);
                          },
                        ),
                      ),

                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: CircularProgressIndicator(),
                        ),

                      // Quick replies row
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          children: [
                            _QuickReplyButton(
                                label: "Search Book",
                                onTap: () {
                                  _sendMessage("Search Book");
                                }),
                            _QuickReplyButton(
                                label: "Latest Books",
                                onTap: () {
                                  _sendMessage("Latest Books");
                                }),
                            _QuickReplyButton(
                                label: "Recommendations",
                                onTap: () {
                                  _sendMessage("Recommendations");
                                }),
                          ],
                        ),
                      ),

                      // Input field
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                textInputAction: TextInputAction.send,
                                onSubmitted: _sendMessage,
                                decoration: InputDecoration(
                                  hintText: "Enter your query",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide.none,
                                  ),
                                  fillColor: Colors.grey[100],
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 0),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.send, color: Colors.indigo),
                              onPressed: () {
                                _sendMessage(_controller.text);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickReplyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickReplyButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: Colors.grey[200],
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(fontSize: 13)),
      ),
    );
  }
}

enum Sender { user, bot }

class _ChatMessage {
  final String text;
  final Sender sender;
  _ChatMessage({required this.text, required this.sender});
}
