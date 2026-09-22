import 'package:flutter/material.dart';

class NewArrivalsScreen extends StatefulWidget {
  const NewArrivalsScreen({super.key});

  @override
  State<NewArrivalsScreen> createState() => _NewArrivalsScreenState();
}

class _NewArrivalsScreenState extends State<NewArrivalsScreen> {
  final List<Map<String, String>> books = [
    {"title": "The Power of Habit", "author": "Charles Duhigg"},
    {"title": "Atomic Habits", "author": "James Clear"},
    {"title": "Deep Work", "author": "Cal Newport"},
    {"title": "Rich Dad Poor Dad", "author": "Robert Kiyosaki"},
    {"title": "The Psychology of Money", "author": "Morgan Housel"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Arrivals"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.indigo.shade100,
                child: Icon(Icons.book, color: Colors.indigo.shade800),
              ),
              title: Text(
                book["title"]!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(book["author"]!),
            ),
          );
        },
      ),
    );
  }
}
