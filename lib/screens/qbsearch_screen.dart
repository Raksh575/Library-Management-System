import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import '../utils/web_open.dart' if (dart.library.html) '../utils/web_open_web.dart';
import '../data/resource_store.dart';
import '../models/question_bank.dart' as qb_model;

class QuestionBankScreen extends StatefulWidget {
  const QuestionBankScreen({super.key});

  @override
  State<QuestionBankScreen> createState() => _QuestionBankScreenState();
}

class _QuestionBankScreenState extends State<QuestionBankScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();

  // Backing store and dynamic data
  final ResourceStore _store = ResourceStore.instance;
  List<qb_model.QuestionBank> _all = [];
  List<qb_model.QuestionBank> _filtered = [];
  String _selectedCategory = "All";
  bool _isSearching = false;
  bool _showNoResults = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _all = _store.activeQuestionBanks;
    _filtered = _all;
    _animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
    _store.addListener(_onStoreChanged);
  }

  void _onStoreChanged() {
    _syncFromStore();
    _searchBank(_controller.text);
  }

  void _syncFromStore() {
    setState(() {
      _all = _store.activeQuestionBanks;
      _filtered = _all;
    });
  }

  void _searchBank(String query) {
    final q = query.toLowerCase();
    final results = _all.where((qb) {
      final matchSubject = _selectedCategory == "All" || qb.subject == _selectedCategory;
      return matchSubject &&
          (qb.title.toLowerCase().contains(q) || qb.subject.toLowerCase().contains(q));
    }).toList();

    setState(() {
      _filtered = results;
      _showNoResults = results.isEmpty;
      _isSearching = query.isNotEmpty;
    });
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _filtered = _all;
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

  Future<String?> _preparePdf(qb_model.QuestionBank qb) async {
    final src = qb.fileUrl.trim();
    if (src.isEmpty) return null;
    // Web: return URL/data URL directly
    if (kIsWeb) {
      if (src.startsWith('http://') || src.startsWith('https://') || src.startsWith('data:')) {
        return src;
      }
      return null;
    }
    // If it's a remote URL, download to app docs
    if (src.startsWith('http://') || src.startsWith('https://')) {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final filePath = "${dir.path}/${src.split('/').last}";
        final file = File(filePath);
        if (!file.existsSync()) {
          await Dio().download(src, filePath);
        }
        return filePath;
      } catch (_) {
        return null;
      }
    }
    // If it's an asset path
    if (src.startsWith('assets/')) {
      try {
        final byteData = await rootBundle.load(src);
        final temp = await getTemporaryDirectory();
        final file = File('${temp.path}/${src.split('/').last}');
        await file.writeAsBytes(byteData.buffer.asUint8List());
        return file.path;
      } catch (_) {
        return null;
      }
    }
    // Otherwise treat as local filesystem path
    final file = File(src);
    if (await file.exists()) return file.path;
    return null;
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ["All", ...{for (final qb in _all) qb.subject}].toList();

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
                      itemCount: subjects.length,
                      itemBuilder: (context, index) {
                        final cat = subjects[index];
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
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final qb = _filtered[index];
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: randomColor(),
                        child: const Icon(Icons.folder_open, color: Colors.white),
                      ),
                      title: Text(
                        qb.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("${qb.subject} | Sem ${qb.semester} | ${qb.year}"),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          color: Colors.indigo),
                      onTap: () async {
                        final prepared = await _preparePdf(qb);
                        if (prepared == null) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Unable to open file')),
                            );
                          }
                          return;
                        }
                        if (kIsWeb) {
                          // On web, use WebOpen helper (data: -> open/download, http -> new tab)
                          await WebOpen.open(prepared, filename: qb.title);
                          return;
                        }
                        final lower = prepared.toLowerCase();
                        if (lower.endsWith('.pdf')) {
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PDFViewerPage(filePath: prepared),
                            ),
                          );
                        } else {
                          await OpenFilex.open(prepared);
                        }
                      },
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
