import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';

class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    final saved = await LocalStorageService.loadSuggestions();
    setState(() {
      _suggestions = saved.isNotEmpty
          ? saved
          : [
        "Design Patterns by Gang of Four",
        "Effective Java (3rd Edition)",
        "Domain-Driven Design",
      ];
    });
  }

  Future<void> _addSuggestion(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _suggestions.add(text.trim());
    });

    await LocalStorageService.saveSuggestions(_suggestions);
    _controller.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Suggestion sent to admin!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggestions'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddSuggestionDialog();
        },
        icon: const Icon(Icons.add_comment_rounded),
        label: const Text("Add Suggestion"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigo,
      ),

      body: _suggestions.isEmpty
          ? const Center(child: Text("No suggestions yet. Add one!"))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFAA00FF), Color(0xFFFF4081)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: const Icon(Icons.lightbulb_outline, color: Colors.white),
              title: Text(
                _suggestions[index],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  void _showAddSuggestionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Suggestion"),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: "Enter your suggestion",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              _addSuggestion(_controller.text);
              Navigator.pop(context);
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }
}
