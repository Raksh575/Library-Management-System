import 'package:flutter/material.dart';
import '../models/news.dart';

class AddEditNewsScreen extends StatefulWidget {
  final News? news; // Make it nullable

  const AddEditNewsScreen({super.key, this.news}); // not required now

  @override
  State<AddEditNewsScreen> createState() => _AddEditNewsScreenState();
}

class _AddEditNewsScreenState extends State<AddEditNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.news?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.news?.description ?? '');
    _contentController =
        TextEditingController(text: widget.news?.content ?? '');
  }

  // Example save logic
  void _saveNews() {
    if (_formKey.currentState!.validate()) {
      if (widget.news == null) {
        // Add new
        print("Adding new news");
      } else {
        // Edit existing
        print("Editing existing news");
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.news != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit News' : 'Add News'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                v!.isEmpty ? 'Title cannot be empty' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) =>
                v!.isEmpty ? 'Description cannot be empty' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 4,
                validator: (v) =>
                v!.isEmpty ? 'Content cannot be empty' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveNews,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
                child: Text(isEditing ? 'Save Changes' : 'Add News'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
