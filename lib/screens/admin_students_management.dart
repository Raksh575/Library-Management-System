import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import 'add_edit_student.dart';

class AdminStudentsManagementScreen extends StatefulWidget {
  const AdminStudentsManagementScreen({super.key});

  @override
  State<AdminStudentsManagementScreen> createState() => _AdminStudentsManagementScreenState();
}

class _AdminStudentsManagementScreenState extends State<AdminStudentsManagementScreen> {
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _filtered = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final users = await LocalStorageService.loadUsers();
    setState(() {
      _students = users;
      _filtered = users;
    });
  }

  void _search(String q) {
    setState(() {
      if (q.isEmpty) {
        _filtered = List.of(_students);
      } else {
        _filtered = _students.where((u) {
          final name = (u['name'] ?? '').toString().toLowerCase();
          final email = (u['email'] ?? '').toString().toLowerCase();
          return name.contains(q.toLowerCase()) || email.contains(q.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _add() async {
    final changed = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const AddEditStudentScreen()));
    if (changed == true) await _load();
  }

  Future<void> _edit(Map<String, dynamic> student) async {
    final changed = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => AddEditStudentScreen(student: student)));
    if (changed == true) await _load();
  }

  Future<void> _delete(String email) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Student'),
        content: Text('Are you sure you want to remove "$email"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      final users = await LocalStorageService.loadUsers();
      users.removeWhere((u) => (u['email'] ?? '').toString().toLowerCase() == email.toLowerCase());
      await LocalStorageService.saveUsers(users);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student removed')));
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Students'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _add),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by name or email',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _search,
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(child: Text('No students found'))
                : ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final u = _filtered[index];
                      final name = (u['name'] ?? '').toString();
                      final email = (u['email'] ?? '').toString();
                      final registeredAt = u['registeredAtMs'] is int ? DateTime.fromMillisecondsSinceEpoch(u['registeredAtMs'] as int) : null;
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.account_circle, color: Colors.indigo),
                          title: Text(name.isEmpty ? email : name),
                          subtitle: Text(email + (registeredAt != null ? '\nRegistered: ' + registeredAt.toString() : '')),
                          isThreeLine: registeredAt != null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(onPressed: () => _edit(u), icon: const Icon(Icons.edit, color: Colors.indigo)),
                              IconButton(onPressed: () => _delete(email), icon: const Icon(Icons.delete, color: Colors.redAccent)),
                            ],
                          ),
                          onTap: () => _edit(u),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}
