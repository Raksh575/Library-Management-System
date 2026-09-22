import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/shimmer_skeleton.dart';


class EResourcesScreen extends StatefulWidget {
  const EResourcesScreen({super.key});

  @override
  State<EResourcesScreen> createState() => _EResourcesScreenState();
}

class _EResourcesScreenState extends State<EResourcesScreen> {
  List<Map<String, String>> _resources = [];
  bool _loading = true;

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
      _loading = false;
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
        automaticallyImplyLeading: true,
      ),
      body: _loading
          ? const ShimmerList()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _resources.length,
        itemBuilder: (context, i) {
          final r = _resources[i];
          return Dismissible(
            key: ValueKey(r["url"]!),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete, color: Colors.red),
            ),
            onDismissed: (direction) async {
              final keyUrl = r["url"]!;
              Map<String, String>? removed;
              _resources.removeWhere((e) {
                final match = e["url"] == keyUrl;
                if (match) removed = e;
                return match;
              });
              setState(() {});
              await LocalStorageService.saveResources(_resources);
              if (removed != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Removed: ${removed!["title"]}')),
                );
              }
            },
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(r["title"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(r["url"]!),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.open_in_new, color: Colors.indigo),
                      onPressed: () => _openUrl(r["url"]!),
                      tooltip: 'Open',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () async {
                        final keyUrl = r["url"]!;
                        Map<String, String>? removed;
                        _resources.removeWhere((e) {
                          final match = e["url"] == keyUrl;
                          if (match) removed = e;
                          return match;
                        });
                        setState(() {});
                        await LocalStorageService.saveResources(_resources);
                        if (removed != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Removed: ${removed!["title"]}')),
                          );
                        }
                      },
                      tooltip: 'Delete',
                    ),
                  ],
                ),
                onTap: () => _openUrl(r["url"]!),
              ),
            ),
          );
        },
      ),
    );
  }
}
