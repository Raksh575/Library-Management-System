import 'package:flutter/material.dart';
import '../models/news.dart';
import '../services/local_storage_service.dart';

class NewsClippingScreen extends StatefulWidget {
  const NewsClippingScreen({super.key});

  @override
  State<NewsClippingScreen> createState() => _NewsClippingScreenState();
}

class _NewsClippingScreenState extends State<NewsClippingScreen> {
  List<News> _newsList = [];

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    final data = await LocalStorageService.loadNewsList();
    setState(() => _newsList = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('News Clipping')),
      body: _newsList.isEmpty
          ? const Center(child: Text('No news available'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _newsList.length,
        itemBuilder: (context, index) {
          final news = _newsList[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(news.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(news.description),
              onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(news.title),
                  content: Text(news.content),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
