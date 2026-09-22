import 'package:flutter/material.dart';
import '../models/question_bank.dart' as qb_model;
import '../data/resource_store.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:convert';

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
  final _pdfUrlController = TextEditingController();
  final ResourceStore _store = ResourceStore.instance;
  String? _pickedFileName;

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
      _pdfUrlController.text = widget.questionBank!.fileUrl;
    }
  }

  Future<void> _pickLocalPdf() async {
    if (kIsWeb) {
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx'],
          withData: true,
        );
        if (result == null || result.files.single.bytes == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No file selected')),
          );
          return;
        }

        final bytes = result.files.single.bytes!;
        final fileName = result.files.single.name;
        final lower = fileName.toLowerCase();
        String mime = 'application/octet-stream';
        if (lower.endsWith('.pdf')) mime = 'application/pdf';
        else if (lower.endsWith('.docx')) mime = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
        else if (lower.endsWith('.doc')) mime = 'application/msword';
        final base64Data = base64Encode(bytes);
        final dataUrl = 'data:$mime;base64,$base64Data';
        setState(() {
          _pdfUrlController.text = dataUrl;
          _pickedFileName = fileName;
          if (_typeController.text.isEmpty) {
            _typeController.text = 'online';
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attached $fileName')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to attach file: $e')),
        );
      }
      return;
    }
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );
      if (result == null || result.files.single.path == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file selected')),
        );
        return;
      }

      final srcPath = result.files.single.path!;
      final fileName = result.files.single.name;
      final docsDir = await getApplicationDocumentsDirectory();
      final destPath = '${docsDir.path}/qb_${DateTime.now().millisecondsSinceEpoch}_$fileName';
      await File(srcPath).copy(destPath);

      setState(() {
        _pdfUrlController.text = destPath;
        _pickedFileName = fileName;
        if (_typeController.text.isEmpty) {
          _typeController.text = 'offline';
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attached $fileName')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to attach file: $e')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _semesterController.dispose();
    _yearController.dispose();
    _typeController.dispose();
    _pdfUrlController.dispose();
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
        isActive: widget.questionBank?.isActive ?? true,
        fileUrl: _pdfUrlController.text.trim(),
      );

      if (widget.questionBank != null) {
        _store.updateQuestionBank(questionBank);
      } else {
        _store.addQuestionBank(questionBank);
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
                  labelText: 'Type (online/offline or exam type)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Offline PDF attachment
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pdfUrlController,
                      decoration: InputDecoration(
                        labelText: 'Attached file (local path)',
                        border: const OutlineInputBorder(),
                        hintText: 'Pick a local PDF/DOC/DOCX',
                        prefixIcon: const Icon(Icons.attach_file),
                        suffixIcon: _pdfUrlController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _pdfUrlController.clear();
                                    _pickedFileName = null;
                                  });
                                },
                              )
                            : null,
                      ),
                      keyboardType: TextInputType.url,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _pickLocalPdf,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Attach File'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                  ),
                ],
              ),
              if (_pickedFileName != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Selected: $_pickedFileName', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ),
              ],
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