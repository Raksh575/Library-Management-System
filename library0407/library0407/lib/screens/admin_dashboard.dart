import 'package:flutter/material.dart';
import '../data/demo_store.dart';
import '../data/resource_store.dart';
import '../services/local_storage_service.dart';
import 'admin_book_management.dart';
import 'admin_journal_management.dart';
import 'admin_question_bank_management.dart';
import 'admin_news_management.dart';
import 'admin_add_resource.dart';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.indigo,
                      child: Icon(Icons.admin_panel_settings,
                          color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Admin Panel",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Complete Library Management System",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Statistics Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                  'Total Books',
                  bookStore.totalBooks.toString(),
                  Icons.library_books,
                  Colors.blue,
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
                  _openAddResourcePage, // ✅ New handler
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
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
