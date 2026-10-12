import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/local_storage_service.dart';

class EResourcesScreen extends StatefulWidget {
  const EResourcesScreen({super.key});

  @override
  State<EResourcesScreen> createState() => _EResourcesScreenState();
}

class _EResourcesScreenState extends State<EResourcesScreen> {
  List<Map<String, String>> _resources = [];

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    final saved = await LocalStorageService.loadResources();
    setState(() {
      _resources = saved.isNotEmpty
          ? saved
          : [
        {"title": "IEEE Library", "url": "https://ieeexplore.ieee.org"},
        {"title": "SpringerLink", "url": "https://link.springer.com"},
        {"title": "ScienceDirect", "url": "https://www.sciencedirect.com"},
        {"title": "Google Scholar", "url": "https://scholar.google.com"},
      ];
    });
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open link")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Resources'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _resources.length,
        itemBuilder: (context, i) {
          final r = _resources[i];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(r["title"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(r["url"]!),
              trailing: const Icon(Icons.open_in_new, color: Colors.indigo),
              onTap: () => _openUrl(r["url"]!),
            ),
          );
        },
      ),
    );
  }
}
