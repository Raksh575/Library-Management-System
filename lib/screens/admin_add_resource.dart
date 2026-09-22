import 'package:flutter/material.dart';

class AdminAddResourceScreen extends StatefulWidget {
  const AdminAddResourceScreen({super.key});

  @override
  State<AdminAddResourceScreen> createState() => _AdminAddResourceScreenState();
}

class _AdminAddResourceScreenState extends State<AdminAddResourceScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add E-Resource")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Resource Title"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(labelText: "Resource URL"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final title = _titleController.text.trim();
                final url = _urlController.text.trim();
                if (title.isNotEmpty && url.isNotEmpty) {
                  Navigator.pop(context, {"title": title, "url": url});
                }
              },
              child: const Text("Save Resource"),
            )
          ],
        ),
      ),
    );
  }
}
