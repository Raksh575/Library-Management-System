import 'package:flutter/material.dart';

class JournalSearchScreen extends StatefulWidget {
  const JournalSearchScreen({super.key});

  @override
  State<JournalSearchScreen> createState() => _JournalSearchScreenState();
}

class _JournalSearchScreenState extends State<JournalSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  final List<String> _journals = [
    "Nature",
    "IEEE Transactions on Computers",
    "ACM Computing Surveys",
    "Science",
    "Journal of AI Research",
    "Journal of Machine Learning Research",
    "Elsevier: Data & Knowledge Engineering",
  ];

  List<String> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = _journals; // Show all journals initially
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
      body: Padding(
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
                        // 👇 Later you can navigate to journal details page here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Opening "$item"...')),
                        );
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
