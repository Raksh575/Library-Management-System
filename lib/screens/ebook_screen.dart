import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

// For Flutter Web
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class EBookScreen extends StatefulWidget {
  const EBookScreen({super.key});

  @override
  State<EBookScreen> createState() => _EBookScreenState();
}

class _EBookScreenState extends State<EBookScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController searchController = TextEditingController();
  List books = [];
  List favorites = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchBooks("flutter");
  }

  Future<void> fetchBooks(String query) async {
    setState(() => isLoading = true);
    final url =
        "https://www.googleapis.com/books/v1/volumes?q=$query&maxResults=20";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          books = data["items"] ?? [];
        });
      } else {
        throw Exception("Failed to load books");
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void toggleFavorite(Map book) {
    final title = book["volumeInfo"]["title"];
    final isFav = favorites.any((fav) => fav["volumeInfo"]["title"] == title);

    setState(() {
      if (isFav) {
        favorites.removeWhere((fav) => fav["volumeInfo"]["title"] == title);
      } else {
        favorites.add(book);
      }
    });
  }

  bool isFavorite(String title) {
    return favorites.any((fav) => fav["volumeInfo"]["title"] == title);
  }

  void openPreview(String title, String? previewLink) {
    if (previewLink != null && previewLink.isNotEmpty) {
      if (kIsWeb) {
        html.window.open(previewLink, '_blank');
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WebPreviewPage(url: previewLink, title: title),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No preview available")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // removes back button
        //title: const Text(
          //"E-Books Store",
          //style: TextStyle(color: Colors.white),
       // ),
        backgroundColor: Colors.indigo,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white, // selected tab color
          unselectedLabelColor: Colors.white70, // unselected tab color
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Books"),
            Tab(text: "Favorites"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildBooksTab(),
          buildFavoritesTab(),
        ],
      ),
    );
  }

  Widget buildBooksTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            onSubmitted: (value) {
              if (value.isNotEmpty) fetchBooks(value);
            },
            decoration: InputDecoration(
              hintText: "Search books...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : books.isEmpty
              ? const Center(child: Text("No books found"))
              : ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index]["volumeInfo"];
              final title = book["title"] ?? "No Title";
              final authors =
              (book["authors"] ?? ["Unknown"]).join(", ");
              final previewLink = book["previewLink"];
              final fullBook = books[index];
              final fav = isFavorite(title);

              return Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: ListTile(
                  title: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    authors,
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  trailing: Wrap(
                    spacing: 10,
                    children: [
                      IconButton(
                        icon: Icon(
                          fav
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.red,
                        ),
                        onPressed: () => toggleFavorite(fullBook),
                      ),
                      IconButton(
                        icon: const Icon(Icons.visibility,
                            color: Colors.indigo),
                        onPressed: () =>
                            openPreview(title, previewLink),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildFavoritesTab() {
    if (favorites.isEmpty) {
      return const Center(child: Text("No favorite books yet"));
    }

    return ListView.builder(
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final book = favorites[index]["volumeInfo"];
        final title = book["title"] ?? "No Title";
        final authors = (book["authors"] ?? ["Unknown"]).join(", ");
        final previewLink = book["previewLink"];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          child: ListTile(
            title: Text(
              title,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              authors,
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            trailing: Wrap(
              spacing: 10,
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () => toggleFavorite(favorites[index]),
                ),
                IconButton(
                  icon:
                  const Icon(Icons.visibility, color: Colors.indigo),
                  onPressed: () => openPreview(title, previewLink),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class WebPreviewPage extends StatelessWidget {
  final String url;
  final String title;
  const WebPreviewPage({super.key, required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.indigo,
      ),
      body: WebViewWidget(
        controller: WebViewController()..loadRequest(Uri.parse(url)),
      ),
    );
  }
}
