import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/demo_store.dart';
import '../data/resource_store.dart';
import '../services/local_storage_service.dart';

class AdminReportScreen extends StatefulWidget {
  const AdminReportScreen({super.key});

  @override
  State<AdminReportScreen> createState() => _AdminReportScreenState();
}

class _AdminReportScreenState extends State<AdminReportScreen> {
  final DemoStore _bookStore = DemoStore.instance;
  final ResourceStore _resourceStore = ResourceStore.instance;

  int _studentsCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final users = await LocalStorageService.loadUsers();
    if (!mounted) return;
    setState(() {
      _studentsCount = users.length;
      _loading = false;
    });
  }

  String _generateCsv() {
    final lines = <String>[];
    lines.add('Section,Metric,Value');
    // Books
    lines.add('Books,Total,${_bookStore.totalBooks}');
    lines.add('Books,Available,${_bookStore.availableBooks}');
    lines.add('Books,Issued,${_bookStore.issuedBooks}');
    lines.add('Books,Reserved,${_bookStore.reservedBooks}');
    // Resources
    lines.add('Resources,Journals,${_resourceStore.journals.length}');
    lines.add('Resources,Question Banks,${_resourceStore.questionBanks.length}');
    lines.add('Resources,News,${_resourceStore.news.length}');
    // Students
    lines.add('Users,Students,${_studentsCount}');

    // Reserved books details
    lines.add('');
    lines.add('Reserved Books');
    lines.add('Title,Author,Reserved By');
    for (final b in _bookStore.books.where((b) => b.isReserved)) {
      final by = (b.reservedBy ?? '').toString().replaceAll(',', ' ');
      lines.add('${b.title.replaceAll(',', ' ')},${b.author.replaceAll(',', ' ')},$by');
    }

    return lines.join('\n');
  }

  Future<void> _copyCsv() async {
    final csv = _generateCsv();
    await Clipboard.setData(ClipboardData(text: csv));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report CSV copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Reports'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Copy CSV',
            icon: const Icon(Icons.copy_all),
            onPressed: _loading ? null : _copyCsv,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _stat('Total Books', _bookStore.totalBooks.toString(), Icons.library_books, Colors.indigo),
                      _stat('Available', _bookStore.availableBooks.toString(), Icons.check_circle, Colors.green),
                      _stat('Issued', _bookStore.issuedBooks.toString(), Icons.assignment_turned_in, Colors.orange),
                      _stat('Reserved', _bookStore.reservedBooks.toString(), Icons.bookmark, Colors.redAccent),
                      _stat('Journals', _resourceStore.journals.length.toString(), Icons.article, Colors.teal),
                      _stat('Q-Banks', _resourceStore.questionBanks.length.toString(), Icons.quiz, Colors.deepPurple),
                      _stat('News', _resourceStore.news.length.toString(), Icons.newspaper, Colors.purple),
                      _stat('Students', _studentsCount.toString(), Icons.people, Colors.blueGrey),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _copyCsv,
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy CSV Summary'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Reserved Books', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_bookStore.books.where((b) => b.isReserved).isEmpty)
                    const Text('No current reservations')
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _bookStore.books.where((b) => b.isReserved).length,
                      itemBuilder: (context, index) {
                        final reserved = _bookStore.books.where((b) => b.isReserved).toList();
                        final b = reserved[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.menu_book, color: Colors.indigo),
                            title: Text(b.title),
                            subtitle: Text('by ${b.author}${b.reservedBy != null ? ' • ${b.reservedBy}' : ''}'),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Widget _stat(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.02)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 22, backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
