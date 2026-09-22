import 'package:flutter/material.dart';
import '../data/demo_store.dart';
import '../data/resource_store.dart';
import '../services/local_storage_service.dart';
import 'admin_book_management.dart';
import 'admin_journal_management.dart';
import 'admin_question_bank_management.dart';
import 'admin_news_management.dart';
import 'admin_add_resource.dart';
import 'admin_students_management.dart';
import 'admin_report_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final bookStore = DemoStore.instance;
  final resourceStore = ResourceStore.instance;

  List<Map<String, String>> _resources = [];

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    final data = await LocalStorageService.loadResources();
    setState(() => _resources = data);
  }

  Future<void> _openAddResourcePage() async {
    final newResource = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminAddResourceScreen()),
    );

    if (newResource != null && newResource is Map<String, String>) {
      setState(() {
        _resources.add(newResource);
      });
      await LocalStorageService.saveResources(_resources);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New resource added successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: bookStore,
        builder: (context, _) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 6)),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.admin_panel_settings, color: Colors.indigo, size: 30),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Admin Panel",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Complete Library Management System",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Recent Reservations
            if (bookStore.books.any((b) => b.isReserved))
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Recent Reservations', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      ...bookStore.books
                          .where((b) => b.isReserved)
                          .take(5)
                          .map((b) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    const Icon(Icons.bookmark, color: Colors.orange),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(b.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                          if (b.reservedBy != null && b.reservedBy!.isNotEmpty)
                                            Text('by ${b.reservedBy}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => const AdminBookManagementScreen()),
                                        );
                                      },
                                      child: const Text('Manage'),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                      onPressed: () => bookStore.unreserveBook(b.id),
                                      icon: const Icon(Icons.close, size: 16),
                                      label: const Text('Clear'),
                                    ),
                                  ],
                                ),
                              ))
                          ,
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ActionChip(
                    label: const Text('Books'),
                    avatar: const Icon(Icons.menu_book, size: 18),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminBookManagementScreen()),
                      );
                    },
                  ),
                  ActionChip(
                    label: const Text('Students'),
                    avatar: const Icon(Icons.people, size: 18),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminStudentsManagementScreen()),
                      );
                    },
                  ),
                  ActionChip(
                    label: const Text('Journals'),
                    avatar: const Icon(Icons.article, size: 18),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminJournalManagementScreen()),
                      );
                    },
                  ),
                  ActionChip(
                    label: const Text('Q-Bank'),
                    avatar: const Icon(Icons.quiz, size: 18),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminQuestionBankManagementScreen()),
                      );
                    },
                  ),
                  ActionChip(
                    label: const Text('News'),
                    avatar: const Icon(Icons.newspaper, size: 18),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminNewsManagementScreen()),
                      );
                    },
                  ),
                  ActionChip(
                    label: const Text('E-Resources'),
                    avatar: const Icon(Icons.link, size: 18),
                    onPressed: _openAddResourcePage,
                  ),
                  ActionChip(
                    label: const Text('Reports'),
                    avatar: const Icon(Icons.bar_chart, size: 18),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminReportScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Statistics Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
              children: [
                _buildStatCard(
                  'Total Books',
                  bookStore.totalBooks.toString(),
                  Icons.library_books,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Reserved Books',
                  bookStore.reservedBooks.toString(),
                  Icons.bookmark,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Journals',
                  resourceStore.journals.length.toString(),
                  Icons.article,
                  Colors.green,
                ),
                _buildStatCard(
                  'Question Papers',
                  resourceStore.questionBanks.length.toString(),
                  Icons.quiz,
                  Colors.orange,
                ),
                _buildStatCard(
                  'News Items',
                  resourceStore.news.length.toString(),
                  Icons.newspaper,
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Resource Management Section
            const Text(
              'Resource Management',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildResourceCard(
                  'Manage Books',
                  Icons.menu_book,
                  Colors.indigo,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const AdminBookManagementScreen(),
                      ),
                    );
                  },
                ),
                _buildResourceCard(
                  'Manage Students',
                  Icons.people,
                  Colors.blueGrey,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const AdminStudentsManagementScreen(),
                      ),
                    );
                  },
                ),
                _buildResourceCard(
                  'Manage Journals',
                  Icons.article,
                  Colors.green,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const AdminJournalManagementScreen(),
                      ),
                    );
                  },
                ),
                _buildResourceCard(
                  'Manage Q-Bank',
                  Icons.quiz,
                  Colors.orange,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const AdminQuestionBankManagementScreen(),
                      ),
                    );
                  },
                ),
                _buildResourceCard(
                  'Manage News',
                  Icons.newspaper,
                  Colors.purple,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const AdminNewsManagementScreen(),
                      ),
                    );
                  },
                ),
                _buildResourceCard(
                  'Manage E-Resources',
                  Icons.link,
                  Colors.teal,
                  _openAddResourcePage,
                ),
                _buildResourceCard(
                  'Reports',
                  Icons.bar_chart,
                  Colors.indigo,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminReportScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.08), color.withOpacity(0.02)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 24, backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color, size: 26)),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(radius: 22, backgroundColor: color.withOpacity(0.12), child: Icon(icon, color: color, size: 24)),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
