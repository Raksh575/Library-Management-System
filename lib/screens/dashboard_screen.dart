import 'package:flutter/material.dart';
import '../data/demo_store.dart';
import '../models/book.dart';
import 'add_edit_book.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme_controller.dart';
import 'qr_scanner_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final store = DemoStore.instance;
    final isDark = ThemeController.instance.isDark;

    return Scaffold(
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) => SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? const [Color(0xFF141E30), Color(0xFF243B55)]
                        : const [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "MCET College Library",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Student One",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const QRScannerScreen()),
                            );
                            if (!mounted) return;
                            if (result is String && result.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('QR: $result')),
                              );
                              // TODO: act on QR if needed (e.g., open book detail)
                            }
                          },
                          icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                        ),
                        IconButton(
                          onPressed: () {
                            ThemeController.instance.toggle();
                            setState(() {});
                          },
                          icon: Icon(isDark ? Icons.light_mode : Icons.palette, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Stats Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildStatItem("Total Books", store.totalBooks.toString(), Icons.menu_book, const Color(0xFF2193b0)),
                    const SizedBox(height: 12),
                    _buildStatItem("Issued Books", store.issuedBooks.toString(), Icons.assignment_turned_in, const Color(0xFFf7971e)),
                    const SizedBox(height: 12),
                    _buildStatItem("Reserved Books", store.reservedBooks.toString(), Icons.bookmark, const Color(0xFF11998e)),
                    const SizedBox(height: 12),
                    _buildStatItem("Late Returns", "0", Icons.error_outline, const Color(0xFFf85032)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  onChanged: (value) {
                    store.searchQuery.value = value.toLowerCase();
                  },
                  decoration: InputDecoration(
                    hintText: "Search books by title or author...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Book List with Search
              ValueListenableBuilder<String>(
                valueListenable: store.searchQuery,
                builder: (context, query, child) {
                  final filteredBooks = store.filteredBooks;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: filteredBooks.map((book) => _buildBookItem(context, book)).toList(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Issued Books Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Issued Books',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ...store.books
                        .where((b) => !b.isAvailable)
                        .map((b) => _buildIssuedItem(context, store, b))
                        ,
                    if (store.books.where((b) => !b.isAvailable).isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.grey),
                            SizedBox(width: 8),
                            Expanded(child: Text('No books are currently issued.')),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditBookScreen()),
          );
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatItem(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookItem(BuildContext context, Book book) {
    final store = DemoStore.instance;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${book.author} · ${book.category}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.shelves, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        "Rack: ${book.rackNumber}",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        book.isAvailable ? Icons.check_circle : Icons.cancel,
                        size: 16,
                        color: book.isAvailable ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        book.isAvailable ? "Available" : "Issued",
                        style: TextStyle(
                          fontSize: 13,
                          color: book.isAvailable ? Colors.green.shade600 : Colors.red.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (book.isReserved)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Text('Reserved', style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                if (!book.isReserved)
                  TextButton.icon(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final name = prefs.getString('name') ?? 'Student';
                      final email = prefs.getString('email') ?? '';
                      final userId = email.isNotEmpty ? '$name <$email>' : name;
                      await store.reserveBook(book.id, userId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Book reserved')));
                      }
                    },
                    icon: const Icon(Icons.bookmark_add, size: 16),
                    label: const Text('Reserve'),
                  )
                else
                  TextButton.icon(
                    onPressed: () async {
                      await store.unreserveBook(book.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reservation cancelled')));
                      }
                    },
                    icon: const Icon(Icons.bookmark_remove, size: 16),
                    label: const Text('Unreserve'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssuedItem(BuildContext context, DemoStore store, Book book) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.assignment_turned_in, color: Colors.orange),
        title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${book.author} • Rack ${book.rackNumber}'),
        trailing: TextButton.icon(
          onPressed: () => store.toggleBookAvailability(book.id),
          icon: const Icon(Icons.undo, size: 16),
          label: const Text('Return'),
        ),
      ),
    );
  }
}