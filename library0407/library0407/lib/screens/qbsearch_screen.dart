import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class QuestionBankScreen extends StatefulWidget {
  const QuestionBankScreen({super.key});

  @override
  State<QuestionBankScreen> createState() => _QuestionBankScreenState();
}

class _QuestionBankScreenState extends State<QuestionBankScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();

  // Question banks data
  final List<Map<String, dynamic>> _questionBanks = [
    {
      "title": "DBMS Paper 2023",
      "author": "Korth",
      "type": "offline",
      "category": "DBMS",
      "file": "assets/dbms_2023.pdf"
    },
    {
      "title": "DBMS Paper 2022",
      "author": "Navathe",
      "type": "online",
      "category": "DBMS",
      "url": "https://www.africau.edu/images/default/sample.pdf"
    },
    {
      "title": "OS Paper 2022",
      "author": "Silberschatz",
      "type": "offline",
      "category": "OS",
      "file": "assets/os_2022.pdf"
    },
    {
      "title": "Computer Networks Paper",
      "author": "Tanenbaum",
      "type": "online",
      "category": "CN",
      "url": "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"
    },
    {
      "title": "AI Paper 2021",
      "author": "Russell",
      "type": "offline",
      "category": "AI",
      "file": "assets/ai_2021.pdf"
    },
    {
      "title": "Python Online Paper",
      "author": "Eric Matthes",
      "type": "online",
      "category": "Python",
      "url": "https://www.africau.edu/images/default/sample.pdf"
    },
  ];

  List<Map<String, dynamic>> _filteredBanks = [];
  String _selectedCategory = "All";
  bool _isSearching = false;
  bool _showNoResults = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _filteredBanks = _questionBanks;
    _animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
  }

  void _searchBank(String query) {
    final results = _questionBanks.where((bank) {
      final q = query.toLowerCase();
      final matchCategory =
          _selectedCategory == "All" || bank["category"] == _selectedCategory;
      return matchCategory &&
          (bank["title"].toLowerCase().contains(q) ||
              bank["author"].toLowerCase().contains(q));
    }).toList();

    setState(() {
      _filteredBanks = results;
      _showNoResults = results.isEmpty;
      _isSearching = query.isNotEmpty;
    });
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _filteredBanks = _questionBanks;
      _isSearching = false;
      _showNoResults = false;
    });
  }

  void _filterCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _searchBank(_controller.text);
  }

  Color randomColor() {
    final colors = [
      Colors.indigo.shade300,
      Colors.deepPurple.shade300,
      Colors.teal.shade300,
      Colors.orange.shade300,
      Colors.pink.shade300
    ];
    return colors[Random().nextInt(colors.length)];
  }

  void _openCategory(Map<String, dynamic> bank) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubjectQuestionBankScreen(
          subject: bank["category"],
          questionBanks: _questionBanks
              .where((b) => b["category"] == bank["category"])
              .toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ["All", "DBMS", "OS", "CN", "AI", "Python"];

    return Scaffold(
      floatingActionButton: _isSearching
          ? FloatingActionButton(
        onPressed: _clearSearch,
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.clear),
      )
          : null,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section
            Container(
              padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Question Bank Finder",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Tap any paper to view all related question banks",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _controller,
                    onChanged: _searchBank,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Search for a question paper...",
                      prefixIcon: const Icon(Icons.search, color: Colors.indigo),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Category Tabs
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final selected = cat == _selectedCategory;
                        return GestureDetector(
                          onTap: () => _filterCategory(cat),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected ? Colors.white : Colors.white24,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                  color: selected ? Colors.indigo : Colors.white,
                                  fontWeight:
                                  selected ? FontWeight.bold : FontWeight.normal),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _showNoResults
                  ? const Center(
                child: Text(
                  "📭 No question papers found",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filteredBanks.length,
                itemBuilder: (context, index) {
                  final bank = _filteredBanks[index];
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: randomColor(),
                        child: const Icon(Icons.folder_open, color: Colors.white),
                      ),
                      title: Text(
                        bank["title"],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("${bank["author"]} | ${bank["category"]}"),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          color: Colors.indigo),
                      onTap: () => _openCategory(bank),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------- CATEGORY PAGE ----------------------

class SubjectQuestionBankScreen extends StatelessWidget {
  final String subject;
  final List<Map<String, dynamic>> questionBanks;

  const SubjectQuestionBankScreen({
    super.key,
    required this.subject,
    required this.questionBanks,
  });

  Future<String?> _downloadPdf(String url) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = "${dir.path}/${url.split('/').last}";
      final file = File(filePath);
      if (!file.existsSync()) {
        await Dio().download(url, filePath);
      }
      return filePath;
    } catch (e) {
      return null;
    }
  }

  Future<String> _copyAssetToLocal(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final file =
    File('${(await getTemporaryDirectory()).path}/${assetPath.split('/').last}');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file.path;
  }

  Future<void> _openPaper(BuildContext context, Map<String, dynamic> bank) async {
    if (bank["type"] == "online") {
      final url = bank["url"];
      final filePath = await _downloadPdf(url);
      if (filePath != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PDFViewerPage(filePath: filePath)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to open online paper")),
        );
      }
    } else {
      final filePath = await _copyAssetToLocal(bank["file"]);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PDFViewerPage(filePath: filePath)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$subject Question Banks"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questionBanks.length,
        itemBuilder: (context, index) {
          final bank = questionBanks[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(
                bank["type"] == "online" ? Icons.cloud_download : Icons.picture_as_pdf,
                color: Colors.indigo,
              ),
              title: Text(bank["title"]),
              subtitle: Text(bank["author"]),
              trailing: const Icon(Icons.open_in_new, color: Colors.indigo),
              onTap: () => _openPaper(context, bank),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------- PDF VIEWER ----------------------

class PDFViewerPage extends StatelessWidget {
  final String filePath;
  const PDFViewerPage({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Question Paper")),
      body: PDFView(
        filePath: filePath,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: true,
        pageFling: true,
      ),
    );
  }
}
