import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';

class AddEditStudentScreen extends StatefulWidget {
  final Map<String, dynamic>? student;
  const AddEditStudentScreen({super.key, this.student});

  @override
  State<AddEditStudentScreen> createState() => _AddEditStudentScreenState();
}

class _AddEditStudentScreenState extends State<AddEditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    if (s != null) {
      _nameController.text = (s['name'] ?? '').toString();
      _emailController.text = (s['email'] ?? '').toString();
      _passwordController.text = (s['password'] ?? '').toString();
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    final users = await LocalStorageService.loadUsers();

    // Prevent duplicate email (except self)
    final existingIndex = users.indexWhere((u) => (u['email'] ?? '').toString().toLowerCase() == email);
    final isEditing = widget.student != null;
    if (existingIndex != -1 && (!isEditing || (users[existingIndex]['email'] as String).toLowerCase() != (widget.student!['email'] as String).toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email already exists')));
      return;
    }

    if (isEditing) {
      final index = users.indexWhere((u) => (u['email'] ?? '').toString().toLowerCase() == (widget.student!['email'] as String).toLowerCase());
      if (index != -1) {
        users[index] = {
          'name': name,
          'email': email,
          'password': password,
          'registeredAtMs': users[index]['registeredAtMs'] ?? DateTime.now().millisecondsSinceEpoch,
          'validUntilMs': users[index]['validUntilMs'] ?? (DateTime.now().millisecondsSinceEpoch + 10 * 60 * 1000),
        };
      }
    } else {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      users.add({
        'name': name,
        'email': email,
        'password': password,
        'registeredAtMs': nowMs,
        'validUntilMs': nowMs + 10 * 60 * 1000,
      });
    }

    await LocalStorageService.saveUsers(users);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.student != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Student' : 'Add Student'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                readOnly: isEditing, // keep email immutable as key
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (!v.contains('@')) return 'Invalid email';
                  if (v.toLowerCase() == 'admin@mcet.in') return 'Reserved email';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) => (v == null || v.trim().length < 4) ? 'Min 4 characters' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(isEditing ? 'Save Changes' : 'Create Student'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
