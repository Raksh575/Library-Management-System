import 'package:flutter/material.dart';
import '../data/resource_store.dart';
// Remove this line: import '../models/journal.dart';
import 'add_edit_journal.dart';

class AdminJournalManagementScreen extends StatefulWidget {
  const AdminJournalManagementScreen({super.key});

  @override
  State<AdminJournalManagementScreen> createState() => _AdminJournalManagementScreenState();
}

class _AdminJournalManagementScreenState extends State<AdminJournalManagementScreen> {
  final ResourceStore _store = ResourceStore.instance;
  final TextEditingController _searchController = TextEditingController();
  List<Journal> _filteredJournals = [];

  @override
  void initState() {
    super.initState();
    _filteredJournals = _store.journals;
  }

  void _searchJournals(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredJournals = _store.journals;
      } else {
        _filteredJournals = _store.journals.where((journal) {
          return journal.title.toLowerCase().contains(query.toLowerCase()) ||
              journal.publisher.toLowerCase().contains(query.toLowerCase()) ||
              journal.category.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _toggleJournalStatus(String id) {
    _store.toggleJournalStatus(id);
    _searchJournals(_searchController.text);
  }

  void _deleteJournal(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Journal'),
        content: const Text('Are you sure you want to delete this journal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _store.deleteJournal(id);
              _searchJournals(_searchController.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Journal deleted successfully')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Journals'),
        backgroundColor: Colors.green, // Changed to green to match journal theme
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditJournalScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _searchJournals,
              decoration: InputDecoration(
                hintText: 'Search journals by title, publisher, or category...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredJournals.length,
              itemBuilder: (context, index) {
                final journal = _filteredJournals[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.article, color: Colors.green),
                    title: Text(
                      journal.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${journal.publisher} • ${journal.category}'),
                        Text('ISSN: ${journal.issn}'),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: journal.isActive
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                journal.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: journal.isActive ? Colors.green : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Text('Edit'),
                          onTap: () {
                            Future.delayed(Duration.zero, () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddEditJournalScreen(journal: journal),
                                ),
                              );
                            });
                          },
                        ),
                        PopupMenuItem(
                          child: Text(
                            journal.isActive ? 'Deactivate' : 'Activate',
                            style: const TextStyle(color: Colors.orange),
                          ),
                          onTap: () => _toggleJournalStatus(journal.id),
                        ),
                        PopupMenuItem(
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                          onTap: () => _deleteJournal(journal.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditJournalScreen(),
            ),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}