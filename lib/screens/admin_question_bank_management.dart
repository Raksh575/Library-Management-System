import 'package:flutter/material.dart';
import '../data/resource_store.dart';
import '../models/question_bank.dart' as qb_model; // Alias to avoid conflict
import 'add_edit_question_bank.dart';

class AdminQuestionBankManagementScreen extends StatefulWidget {
  const AdminQuestionBankManagementScreen({super.key});

  @override
  State<AdminQuestionBankManagementScreen> createState() => _AdminQuestionBankManagementScreenState();
}

class _AdminQuestionBankManagementScreenState extends State<AdminQuestionBankManagementScreen> {
  final ResourceStore _store = ResourceStore.instance;
  final TextEditingController _searchController = TextEditingController();
  List<qb_model.QuestionBank> _filteredQuestionBanks = [];

  @override
  void initState() {
    super.initState();
    _filteredQuestionBanks = _store.questionBanks.cast<qb_model.QuestionBank>();
  }

  void _searchQuestionBanks(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredQuestionBanks = _store.questionBanks.cast<qb_model.QuestionBank>();
      } else {
        _filteredQuestionBanks = _store.questionBanks.where((qb) {
          return qb.title.toLowerCase().contains(query.toLowerCase()) ||
              qb.subject.toLowerCase().contains(query.toLowerCase()) ||
              qb.semester.toLowerCase().contains(query.toLowerCase());
        }).toList().cast<qb_model.QuestionBank>();
      }
    });
  }

  void _toggleQuestionBankStatus(String id) {
    setState(() {
      _store.toggleQuestionBankStatus(id);
      _searchQuestionBanks(_searchController.text);
    });
  }

  void _deleteQuestionBank(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question Paper'),
        content: const Text('Are you sure you want to delete this question paper?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _store.deleteQuestionBank(id);
              setState(() {
                _searchQuestionBanks(_searchController.text);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Question paper deleted successfully')),
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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Manage Question Bank'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditQuestionBankScreen(),
                ),
              ).then((_) {
                // Refresh the list when returning from add/edit screen
                setState(() {
                  _searchQuestionBanks(_searchController.text);
                });
              });
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
              onChanged: _searchQuestionBanks,
              decoration: InputDecoration(
                hintText: 'Search question papers by title, subject, or semester...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchQuestionBanks('');
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredQuestionBanks.length,
              itemBuilder: (context, index) {
                final qb = _filteredQuestionBanks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: ListTile(
                    leading: const Icon(Icons.quiz, color: Colors.orange),
                    title: Text(
                      qb.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${qb.subject} • Semester ${qb.semester} • ${qb.year}'),
                        Text('Type: ${qb.type}'),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: qb.isActive
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                qb.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: qb.isActive ? Colors.green : Colors.red,
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
                                  builder: (context) => AddEditQuestionBankScreen(questionBank: qb),
                                ),
                              ).then((_) {
                                // Refresh the list when returning from edit screen
                                setState(() {
                                  _searchQuestionBanks(_searchController.text);
                                });
                              });
                            });
                          },
                        ),
                        PopupMenuItem(
                          child: Text(
                            qb.isActive ? 'Deactivate' : 'Activate',
                            style: const TextStyle(color: Colors.orange),
                          ),
                          onTap: () => _toggleQuestionBankStatus(qb.id),
                        ),
                        PopupMenuItem(
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                          onTap: () => _deleteQuestionBank(qb.id),
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
              builder: (context) => const AddEditQuestionBankScreen(),
            ),
          ).then((_) {
            // Refresh the list when returning from add screen
            setState(() {
              _searchQuestionBanks(_searchController.text);
            });
          });
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}