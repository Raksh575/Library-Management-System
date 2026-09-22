import 'package:flutter/material.dart';
import '../data/resource_store.dart';
import '../models/news.dart' as news_model; // Alias to avoid conflict
import 'add_edit_news.dart';

class AdminNewsManagementScreen extends StatefulWidget {
  const AdminNewsManagementScreen({super.key});

  @override
  State<AdminNewsManagementScreen> createState() => _AdminNewsManagementScreenState();
}

class _AdminNewsManagementScreenState extends State<AdminNewsManagementScreen> {
  final ResourceStore _store = ResourceStore.instance;
  final TextEditingController _searchController = TextEditingController();
  List<news_model.News> _filteredNews = [];
  @override
  void initState() {
    super.initState();
    _filteredNews = _store.news.cast<news_model.News>(); // Cast the list
  }

  void _searchNews(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredNews = _store.news.cast<news_model.News>();
      } else {
        _filteredNews = _store.news.where((news) {
          return news.title.toLowerCase().contains(query.toLowerCase()) ||
              news.description.toLowerCase().contains(query.toLowerCase());
        }).toList().cast<news_model.News>();
      }
    });
  }


  void _toggleNewsStatus(String id) {
    setState(() {
      _store.toggleNewsStatus(id);
      _searchNews(_searchController.text);
    });
  }

  void _deleteNews(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete News'),
        content: const Text('Are you sure you want to delete this news item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _store.deleteNews(id);
              setState(() {
                _searchNews(_searchController.text);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('News deleted successfully')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Manage News'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditNewsScreen(),
                ),
              ).then((_) {
                // Refresh the list when returning from add/edit screen
                setState(() {
                  _searchNews(_searchController.text);
                });
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _searchNews,
              decoration: InputDecoration(
                hintText: 'Search news by title or description...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchNews('');
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredNews.length,
              itemBuilder: (context, index) {
                final news = _filteredNews[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: ListTile(
                    leading: const Icon(Icons.newspaper, color: Colors.purple),
                    title: Text(
                      news.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(news.description),
                        Text('${news.likes} likes • ${news.comments} comments'),
                        Text('Date: ${news.date.toString().split(' ')[0]}'),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: news.isActive
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                news.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: news.isActive ? Colors.green : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Text('Edit'),
                          onTap: () {
                            Future.delayed(Duration.zero, () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddEditNewsScreen(news: news),
                                ),
                              ).then((_) {
                                // Refresh the list when returning from edit screen
                                setState(() {
                                  _searchNews(_searchController.text);
                                });
                              });
                            });
                          },
                        ),
                        PopupMenuItem(
                          child: Text(
                            news.isActive ? 'Deactivate' : 'Activate',
                            style: const TextStyle(color: Colors.orange),
                          ),
                          onTap: () => _toggleNewsStatus(news.id),
                        ),
                        PopupMenuItem(
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                          onTap: () => _deleteNews(news.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditNewsScreen(),
            ),
          ).then((_) {
            // Refresh the list when returning from add screen
            setState(() {
              _searchNews(_searchController.text);
            });
          });
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}