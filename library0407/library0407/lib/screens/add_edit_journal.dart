import 'package:flutter/material.dart';
import '../data/resource_store.dart';

class AddEditJournalScreen extends StatefulWidget {
  final Journal? journal;
  const AddEditJournalScreen({super.key, this.journal});

  @override
  State<AddEditJournalScreen> createState() => _AddEditJournalScreenState();
}

class _AddEditJournalScreenState extends State<AddEditJournalScreen> {
  final _formKey = GlobalKey<FormState>();
  final ResourceStore _store = ResourceStore.instance;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _publisherController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _issnController = TextEditingController();

  bool _isActive = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.journal != null;
    if (_isEditing) {
      _titleController.text = widget.journal!.title;
      _publisherController.text = widget.journal!.publisher;
      _categoryController.text = widget.journal!.category;
      _issnController.text = widget.journal!.issn;
      _isActive = widget.journal!.isActive;
    }
  }

  void _saveJournal() {
    if (_formKey.currentState!.validate()) {
      final journal = Journal(
        id: _isEditing ? widget.journal!.id : DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        publisher: _publisherController.text.trim(),
        category: _categoryController.text.trim(),
        issn: _issnController.text.trim(),
        isActive: _isActive,
      );

      if (_isEditing) {
        _store.updateJournal(widget.journal!.id, journal);
      } else {
        _store.addJournal(journal);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Journal updated!' : 'Journal added!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Journal' : 'Add New Journal'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Journal Title *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter journal title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _publisherController,
                decoration: const InputDecoration(
                  labelText: 'Publisher *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter publisher name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _issnController,
                decoration: const InputDecoration(
                  labelText: 'ISSN *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter ISSN';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Active'),
                subtitle: const Text('Make this journal visible to students'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveJournal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isEditing ? 'Update Journal' : 'Add Journal',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}