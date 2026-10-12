import 'package:flutter/material.dart';
import '../models/question_bank.dart' as qb_model;
import '../data/resource_store.dart';

class AddEditQuestionBankScreen extends StatefulWidget {
  final qb_model.QuestionBank? questionBank;

  const AddEditQuestionBankScreen({super.key, this.questionBank});

  @override
  State<AddEditQuestionBankScreen> createState() => _AddEditQuestionBankScreenState();
}

class _AddEditQuestionBankScreenState extends State<AddEditQuestionBankScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  final _semesterController = TextEditingController();
  final _yearController = TextEditingController();
  final _typeController = TextEditingController();
  final ResourceStore _store = ResourceStore.instance;

  @override
  void initState() {
    super.initState();
    // If editing existing question bank, populate fields
    if (widget.questionBank != null) {
      _titleController.text = widget.questionBank!.title;
      _subjectController.text = widget.questionBank!.subject;
      _semesterController.text = widget.questionBank!.semester;
      _yearController.text = widget.questionBank!.year;
      _typeController.text = widget.questionBank!.type;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _semesterController.dispose();
    _yearController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  void _saveQuestionBank() {
    if (_formKey.currentState!.validate()) {
      final questionBank = qb_model.QuestionBank(
        id: widget.questionBank?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        subject: _subjectController.text,
        semester: _semesterController.text,
        year: _yearController.text,
        type: _typeController.text,
        isActive: widget.questionBank?.isActive ?? true, fileUrl: '',
      );

      if (widget.questionBank != null) {
        _store.updateQuestionBank(questionBank as QuestionBank);
      } else {
        _store.addQuestionBank(questionBank as QuestionBank);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.questionBank != null ? 'Question paper updated!' : 'Question paper added!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.questionBank != null ? 'Edit Question Paper' : 'Add Question Paper'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a subject';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _semesterController,
                decoration: const InputDecoration(
                  labelText: 'Semester',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a semester';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                  labelText: 'Year',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a year';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Type (e.g., Midterm, Final, Quiz)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveQuestionBank,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(widget.questionBank != null ? 'Update Question Paper' : 'Add Question Paper'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}