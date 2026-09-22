import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Add this import
import '../models/book.dart';

class DemoStore extends ChangeNotifier {
  static final DemoStore _instance = DemoStore._internal();

  factory DemoStore() {
    return _instance;
  }

  DemoStore._internal() {
    _loadBooksFromStorage();
  }

  List<Book> _books = [];
  final ValueNotifier<String> _searchQuery = ValueNotifier('');

  // Getters
  List<Book> get books => List.unmodifiable(_books);
  ValueNotifier<String> get searchQuery => _searchQuery;

  // Statistics
  int get totalBooks => _books.length;
  int get availableBooks => _books.where((book) => book.isAvailable).length;
  int get issuedBooks => _books.where((book) => !book.isAvailable).length;
  int get reservedBooks => _books.where((book) => book.isReserved).length;

  // Load books from local storage
  Future<void> _loadBooksFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final booksJson = prefs.getStringList('library_books');

      if (booksJson != null && booksJson.isNotEmpty) {
        _books = booksJson.map((jsonString) {
          final Map<String, dynamic> jsonMap = json.decode(jsonString);
          return Book.fromJson(jsonMap);
        }).toList();
      } else {
        // Initialize with default books if no data exists
        _books = _getDefaultBooks();
        await _saveBooksToStorage();
      }
      notifyListeners();
    } catch (e) {
      print('Error loading books: $e');
      _books = _getDefaultBooks();
      notifyListeners();
    }
  }

  // Save books to local storage
  Future<void> _saveBooksToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final booksJson = _books.map((book) => json.encode(book.toJson())).toList();
      await prefs.setStringList('library_books', booksJson);
    } catch (e) {
      print('Error saving books: $e');
    }
  }

  // Default books
  List<Book> _getDefaultBooks() {
    return [
      Book(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Flutter for Beginners',
        author: 'Angela Yu',
        category: 'Tech',
        rackNumber: 'A1',
        isAvailable: true,
        isReserved: false,
        reservedBy: null,
      ),
      Book(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        title: 'Clean Code',
        author: 'Robert C. Martin',
        category: 'Programming',
        rackNumber: 'B2',
        isAvailable: true,
        isReserved: false,
        reservedBy: null,
      ),
      Book(
        id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
        title: 'The Pragmatic Programmer',
        author: 'Andrew Hunt',
        category: 'Programming',
        rackNumber: 'C3',
        isAvailable: false,
        isReserved: false,
        reservedBy: null,
      ),
      Book(
        id: (DateTime.now().millisecondsSinceEpoch + 3).toString(),
        title: 'Design Patterns',
        author: 'Erich Gamma',
        category: 'Software Engineering',
        rackNumber: 'D4',
        isAvailable: true,
        isReserved: false,
        reservedBy: null,
      ),
    ];
  }

  // Search functionality
  List<Book> get filteredBooks {
    if (_searchQuery.value.isEmpty) {
      return _books;
    }
    return _books.where((book) {
      return book.title.toLowerCase().contains(_searchQuery.value) ||
          book.author.toLowerCase().contains(_searchQuery.value) ||
          book.category.toLowerCase().contains(_searchQuery.value);
    }).toList();
  }

  // CRUD Operations
  Future<void> addBook(Book book) async {
    _books.add(book);
    await _saveBooksToStorage();
    notifyListeners();
  }

  Future<void> updateBook(String id, Book updatedBook) async {
    final index = _books.indexWhere((book) => book.id == id);
    if (index != -1) {
      _books[index] = updatedBook;
      await _saveBooksToStorage();
      notifyListeners();
    }
  }

  Future<void> deleteBook(String id) async {
    _books.removeWhere((book) => book.id == id);
    await _saveBooksToStorage();
    notifyListeners();
  }

  Future<void> toggleBookAvailability(String id) async {
    final index = _books.indexWhere((book) => book.id == id);
    if (index != -1) {
      _books[index] = _books[index].copyWith(isAvailable: !_books[index].isAvailable);
      await _saveBooksToStorage();
      notifyListeners();
    }
  }

  Future<void> reserveBook(String id, String userId) async {
    final index = _books.indexWhere((book) => book.id == id);
    if (index != -1) {
      if (!_books[index].isReserved) {
        _books[index] = _books[index].copyWith(isReserved: true, reservedBy: userId);
        await _saveBooksToStorage();
        notifyListeners();
      }
    }
  }

  Future<void> unreserveBook(String id) async {
    final index = _books.indexWhere((book) => book.id == id);
    if (index != -1) {
      if (_books[index].isReserved) {
        _books[index] = _books[index].copyWith(isReserved: false, reservedBy: null);
        await _saveBooksToStorage();
        notifyListeners();
      }
    }
  }

  Book? getBookById(String id) {
    try {
      return _books.firstWhere((book) => book.id == id);
    } catch (e) {
      return null;
    }
  }

  // Clear all books (for testing)
  Future<void> clearAllBooks() async {
    _books.clear();
    await _saveBooksToStorage();
    notifyListeners();
  }

  // Reload books from storage
  Future<void> reloadBooks() async {
    await _loadBooksFromStorage();
  }

  // Static instance getter
  static DemoStore get instance => _instance;
}