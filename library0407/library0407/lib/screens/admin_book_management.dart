import 'package:flutter/material.dart';
import '../data/demo_store.dart';
import 'add_edit_book.dart';

class AdminBookManagementScreen extends StatelessWidget {
  const AdminBookManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = DemoStore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Books'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: store.books.length,
        itemBuilder: (context, index) {
          final book = store.books[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.book, color: Colors.indigo),
              title: Text(book.title),
              subtitle: Text('by ${book.author} • ${book.category}'),
              trailing: Icon(
                book.isAvailable ? Icons.check_circle : Icons.cancel,
                color: book.isAvailable ? Colors.green : Colors.red,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditBookScreen()),
          );
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}