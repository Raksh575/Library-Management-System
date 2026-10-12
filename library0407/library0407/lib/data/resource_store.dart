import 'package:flutter/material.dart';

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

class QuestionBank {
  final String id;
  final String title;
  final String subject;
  final String semester;
  final String year;
  final String fileUrl;
  final String type;
  final bool isActive;

  QuestionBank({
    required this.id,
    required this.title,
    required this.subject,
    required this.semester,
    required this.year,
    required this.fileUrl,
    required this.type,
    required this.isActive,
  });

  QuestionBank copyWith({
    String? id,
    String? title,
    String? subject,
    String? semester,
    String? year,
    String? fileUrl,
    String? type,
    bool? isActive,
  }) {
    return QuestionBank(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      semester: semester ?? this.semester,
      year: year ?? this.year,
      fileUrl: fileUrl ?? this.fileUrl,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
    );
  }
}

class News {
  final String id;
  final String title;
  final String description;
  final String content;
  final String imageUrl;
  final DateTime date;
  final int likes;
  final int comments;
  final bool isSaved;
  final bool isActive;

  News({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.imageUrl,
    required this.date,
    required this.likes,
    required this.comments,
    required this.isSaved,
    required this.isActive,
  });

  News copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? imageUrl,
    DateTime? date,
    int? likes,
    int? comments,
    bool? isSaved,
    bool? isActive,
  }) {
    return News(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      date: date ?? this.date,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isSaved: isSaved ?? this.isSaved,
      isActive: isActive ?? this.isActive,
    );
  }
}

class ResourceStore extends ChangeNotifier {
  static final ResourceStore _instance = ResourceStore._internal();

  factory ResourceStore() {
    return _instance;
  }

  ResourceStore._internal() {
    _initializeData();
  }

  List<Journal> _journals = [];
  List<QuestionBank> _questionBanks = [];
  List<News> _news = [];

  // Getters
  List<Journal> get journals => List.unmodifiable(_journals);
  List<QuestionBank> get questionBanks => List.unmodifiable(_questionBanks);
  List<News> get news => List.unmodifiable(_news);

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
      QuestionBank(
        id: '1',
        title: 'DBMS Paper 2023',
        subject: 'Database Management',
        semester: '5',
        year: '2023',
        fileUrl: 'assets/dbms_2023.pdf',
        type: 'offline',
        isActive: true,
      ),
      QuestionBank(
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
      News(
        id: '1',
        title: 'MCET Students Win National Hackathon',
        description: 'An AI-based library automation system won the top prize.',
        content: 'The MCET student team secured the top spot in the National Hackathon 2025...',
        imageUrl: 'https://i.ibb.co/qYj3Kk5/library-news1.jpg',
        date: DateTime.now().subtract(const Duration(days: 2)),
        likes: 12,
        comments: 4,
        isSaved: false,
        isActive: true,
      ),
    ];
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

  void addQuestionBank(QuestionBank questionBank) {
    questionBanks.add(questionBank);
  }

  void updateQuestionBank(QuestionBank updatedQuestionBank) {
    final index = questionBanks.indexWhere((qb) => qb.id == updatedQuestionBank.id);
    if (index != -1) {
      questionBanks[index] = updatedQuestionBank;
    }
  }

  void deleteQuestionBank(String id) {
    questionBanks.removeWhere((qb) => qb.id == id);
  }

  void toggleQuestionBankStatus(String id) {
    final index = questionBanks.indexWhere((qb) => qb.id == id);
    if (index != -1) {
      final currentQB = questionBanks[index];
      // Create a new instance with toggled status
      questionBanks[index] = QuestionBank(
        id: currentQB.id,
        title: currentQB.title,
        subject: currentQB.subject,
        semester: currentQB.semester,
        year: currentQB.year,
        type: currentQB.type,
        isActive: !currentQB.isActive, fileUrl: '',
      );
    }
  }
  // News CRUD Operations
  void addNews(News newsItem) {
    _news.add(newsItem);
    notifyListeners();
  }

  void updateNews(String id, News updatedNews) {
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
  List<QuestionBank> get activeQuestionBanks => _questionBanks.where((qb) => qb.isActive).toList();
  List<News> get activeNews => _news.where((news) => news.isActive).toList();

  // Static instance getter
  static ResourceStore get instance => _instance;
}