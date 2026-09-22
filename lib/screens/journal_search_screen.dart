import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// For Flutter Web
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'journal_webview.dart';
import '../widgets/shimmer_skeleton.dart';

class JournalSearchScreen extends StatefulWidget {
  const JournalSearchScreen({super.key});

  @override
  State<JournalSearchScreen> createState() => _JournalSearchScreenState();
}

class _JournalSearchScreenState extends State<JournalSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = true;

  final List<String> _journals = [
    "Nature",
    "IEEE Transactions on Computers",
    "ACM Computing Surveys",
    "Science",
    "Journal of AI Research",
    "Journal of Machine Learning Research",
    "Elsevier: Data & Knowledge Engineering",
  ];

  final Map<String, String> _journalUrls = const {
    "Nature": "https://www.nature.com/",
    "IEEE Transactions on Computers": "https://ieeexplore.ieee.org/xpl/RecentIssue.jsp?punumber=12",
    "ACM Computing Surveys": "https://dl.acm.org/journal/csur",
    "Science": "https://www.science.org/journal/science",
    "Journal of AI Research": "https://jair.org/index.php/jair",
    "Journal of Machine Learning Research": "https://www.jmlr.org/",
    "Elsevier: Data & Knowledge Engineering": "https://www.sciencedirect.com/journal/data-and-knowledge-engineering",
  };

  List<String> _filtered = [];

  @override
  void initState() {
    super.initState();
    // Simulate initial loading to show shimmer
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() {
        _filtered = _journals; // Show all journals initially
        _loading = false;
      });
    });
  }

  void _search(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = _journals;
      } else {
        _filtered = _journals
            .where((j) => j.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Search Journals",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _loading
          ? const ShimmerList()
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Search Field
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Search Journal Name...",
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.search, color: Colors.indigo),
              ),
              onChanged: _search,
            ),
            const SizedBox(height: 16),

            // 📚 List of Journals
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                child: Text(
                  "No journals found!",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: _filtered.length,
                itemBuilder: (context, i) {
                  final item = _filtered[i];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const Icon(Icons.book_rounded,
                          color: Colors.indigo),
                      title: Text(
                        item,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 18, color: Colors.grey),
                      onTap: () {
                        final url = _journalUrls[item];
                        if (url == null || url.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('No URL configured for "$item"')),
                          );
                          return;
                        }
                        if (kIsWeb) {
                          html.window.open(url, '_blank');
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => JournalWebViewScreen(title: item, url: url),
                            ),
                          );
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
