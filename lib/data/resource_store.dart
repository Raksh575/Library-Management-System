import 'package:flutter/material.dart';
import '../models/question_bank.dart' as qb_model;
import '../models/news.dart' as news_model;
import '../services/local_storage_service.dart';

// Simple models for resources
class Journal {
  final String id;
  final String title;
  final String publisher;
  final String category;
  final String issn;
  final bool isActive;

  Journal({
    required this.id,
    required this.title,
    required this.publisher,
    required this.category,
    required this.issn,
    required this.isActive,
  });

  Journal copyWith({
    String? id,
    String? title,
    String? publisher,
    String? category,
    String? issn,
    bool? isActive,
  }) {
    return Journal(
      id: id ?? this.id,
      title: title ?? this.title,
      publisher: publisher ?? this.publisher,
      category: category ?? this.category,
      issn: issn ?? this.issn,
      isActive: isActive ?? this.isActive,
    );
  }
}

// News model is defined in models/news.dart

class ResourceStore extends ChangeNotifier {
  static final ResourceStore _instance = ResourceStore._internal();

  factory ResourceStore() {
    return _instance;
  }

  ResourceStore._internal() {
    _initializeData();
    _restoreFromPrefs();
  }

  List<Journal> _journals = [];
  List<qb_model.QuestionBank> _questionBanks = [];
  List<news_model.News> _news = [];

  // Getters
  List<Journal> get journals => List.unmodifiable(_journals);
  List<qb_model.QuestionBank> get questionBanks => List.unmodifiable(_questionBanks);
  List<news_model.News> get news => List.unmodifiable(_news);

  // Initialize with sample data
  void _initializeData() {
    _journals = [
      Journal(
        id: '1',
        title: 'Nature',
        publisher: 'Springer Nature',
        category: 'Science',
        issn: '0028-0836',
        isActive: true,
      ),
      Journal(
        id: '2',
        title: 'IEEE Transactions on Computers',
        publisher: 'IEEE',
        category: 'Computer Science',
        issn: '0018-9340',
        isActive: true,
      ),
    ];

    _questionBanks = [
      qb_model.QuestionBank(
        id: '1',
        title: 'DBMS Paper 2023',
        subject: 'Database Management',
        semester: '5',
        year: '2023',
        fileUrl: 'assets/dbms_2023.pdf',
        type: 'offline',
        isActive: true,
      ),
      qb_model.QuestionBank(
        id: '2',
        title: 'OS Paper 2022',
        subject: 'Operating Systems',
        semester: '4',
        year: '2022',
        fileUrl: 'assets/os_2022.pdf',
        type: 'offline',
        isActive: true,
      ),
    ];

    _news = [
      news_model.News(
        id: '1',
        title: 'MCET Students Win National Hackathon',
        description: 'An AI-based library automation system won the top prize.',
        content: 'The MCET student team secured the top spot in the National Hackathon 2025...',
        imageUrl: 'https://i.ibb.co/qYj3Kk5/library-news1.jpg',
        isSaved: false,
        date: DateTime.now().subtract(const Duration(days: 2)),
        likes: 12,
        comments: 4,
        isActive: true,
      ),
    ];
  }

  Future<void> _restoreFromPrefs() async {
    try {
      final stored = await LocalStorageService.loadQuestionBanks();
      if (stored.isNotEmpty) {
        _questionBanks = stored;
        notifyListeners();
      }
    } catch (_) {
      // ignore restore errors
    }
  }

  // Journal CRUD Operations
  void addJournal(Journal journal) {
    _journals.add(journal);
    notifyListeners();
  }

  void updateJournal(String id, Journal updatedJournal) {
    final index = _journals.indexWhere((journal) => journal.id == id);
    if (index != -1) {
      _journals[index] = updatedJournal;
      notifyListeners();
    }
  }

  void deleteJournal(String id) {
    _journals.removeWhere((journal) => journal.id == id);
    notifyListeners();
  }

  void toggleJournalStatus(String id) {
    final index = _journals.indexWhere((journal) => journal.id == id);
    if (index != -1) {
      _journals[index] = _journals[index].copyWith(isActive: !_journals[index].isActive);
      notifyListeners();
    }
  }

  void addQuestionBank(qb_model.QuestionBank questionBank) {
    _questionBanks.add(questionBank);
    notifyListeners();
    LocalStorageService.saveQuestionBanks(_questionBanks);
  }

  void updateQuestionBank(qb_model.QuestionBank updatedQuestionBank) {
    final index = _questionBanks.indexWhere((qb) => qb.id == updatedQuestionBank.id);
    if (index != -1) {
      _questionBanks[index] = updatedQuestionBank;
      notifyListeners();
      LocalStorageService.saveQuestionBanks(_questionBanks);
    }
  }

  void deleteQuestionBank(String id) {
    _questionBanks.removeWhere((qb) => qb.id == id);
    notifyListeners();
    LocalStorageService.saveQuestionBanks(_questionBanks);
  }

  void toggleQuestionBankStatus(String id) {
    final index = _questionBanks.indexWhere((qb) => qb.id == id);
    if (index != -1) {
      final currentQB = _questionBanks[index];
      _questionBanks[index] = currentQB.copyWith(isActive: !currentQB.isActive);
      notifyListeners();
      LocalStorageService.saveQuestionBanks(_questionBanks);
    }
  }

  // News CRUD Operations
  void addNews(news_model.News newsItem) {
    _news.add(newsItem);
    notifyListeners();
  }

  void updateNews(String id, news_model.News updatedNews) {
    final index = _news.indexWhere((news) => news.id == id);
    if (index != -1) {
      _news[index] = updatedNews;
      notifyListeners();
    }
  }

  void deleteNews(String id) {
    _news.removeWhere((news) => news.id == id);
    notifyListeners();
  }

  void toggleNewsStatus(String id) {
    final index = _news.indexWhere((news) => news.id == id);
    if (index != -1) {
      _news[index] = _news[index].copyWith(isActive: !_news[index].isActive);
      notifyListeners();
    }
  }

  // Get active resources for students
  List<Journal> get activeJournals => _journals.where((journal) => journal.isActive).toList();
  List<qb_model.QuestionBank> get activeQuestionBanks => _questionBanks.where((qb) => qb.isActive).toList();
  List<news_model.News> get activeNews => _news.where((news) => news.isActive).toList();

  // Static instance getter
  static ResourceStore get instance => _instance;
}