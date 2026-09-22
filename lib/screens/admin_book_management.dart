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
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final books = store.books;
          if (books.isEmpty) {
            return const Center(child: Text('No books yet. Tap + to add.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.book, color: Colors.indigo),
                  title: Text(book.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('by ${book.author} • ${book.category} • Rack ${book.rackNumber}'),
                      const SizedBox(height: 4),
                      if (book.isReserved)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Text('Reserved', style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      if (book.isReserved && book.reservedBy != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Reserved by: ${book.reservedBy}',
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: book.isAvailable ? 'Mark as unavailable' : 'Mark as available',
                        icon: Icon(
                          book.isAvailable ? Icons.check_circle : Icons.cancel,
                          color: book.isAvailable ? Colors.green : Colors.red,
                        ),
                        onPressed: () => store.toggleBookAvailability(book.id),
                      ),
                      if (book.isReserved)
                        IconButton(
                          tooltip: 'View who reserved',
                          icon: const Icon(Icons.info_outline, color: Colors.orange),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Reservation Details'),
                                content: Text(book.reservedBy != null && book.reservedBy!.isNotEmpty
                                    ? 'Reserved by: ${book.reservedBy}'
                                    : 'Reserved by: Unknown'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      if (book.isReserved)
                        IconButton(
                          tooltip: 'Clear reservation',
                          icon: const Icon(Icons.bookmark_remove, color: Colors.orange),
                          onPressed: () => store.unreserveBook(book.id),
                        ),
                      IconButton(
                        tooltip: 'Edit',
                        icon: const Icon(Icons.edit, color: Colors.indigo),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditBookScreen(book: book),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete book'),
                              content: Text('Are you sure you want to delete "${book.title}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await store.deleteBook(book.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Book deleted'), backgroundColor: Colors.redAccent),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditBookScreen(book: book),
                      ),
                    );
                  },
                ),
              );
            },
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