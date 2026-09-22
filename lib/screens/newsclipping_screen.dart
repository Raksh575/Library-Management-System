import 'package:flutter/material.dart';
import '../models/news.dart';
import '../data/resource_store.dart';
import '../widgets/shimmer_skeleton.dart';

class NewsClippingScreen extends StatefulWidget {
  const NewsClippingScreen({super.key});

  @override
  State<NewsClippingScreen> createState() => _NewsClippingScreenState();
}

class _NewsClippingScreenState extends State<NewsClippingScreen> {
  final ResourceStore _store = ResourceStore.instance;
  List<News> _newsList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _syncFromStore();
    _store.addListener(_onStoreChanged);
  }

  void _onStoreChanged() {
    _syncFromStore();
  }

  void _syncFromStore() {
    setState(() {
      _newsList = _store.activeNews;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const ShimmerList()
          : (_newsList.isEmpty
          ? const Center(child: Text('No news available'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _newsList.length,
        itemBuilder: (context, index) {
          final news = _newsList[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.newspaper, color: Colors.purple),
              title: Text(news.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(news.description),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.purple),
              onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(news.title),
                  content: SingleChildScrollView(child: Text(news.content)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))
                  ],
                ),
              ),
            ),
          );
        },
      )),
    );
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }
}
