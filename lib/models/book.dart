class Book {
  final String id;
  final String title;
  final String author;
  final String category;
  final String rackNumber;
  final bool isAvailable;
  final bool isReserved;
  final String? reservedBy;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.rackNumber,
    required this.isAvailable,
    required this.isReserved,
    this.reservedBy,
  });

  // Convert Book to Map for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'category': category,
      'rackNumber': rackNumber,
      'isAvailable': isAvailable,
      'isReserved': isReserved,
      'reservedBy': reservedBy,
    };
  }

  // Create Book from Map (JSON)
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      category: json['category'] ?? '',
      rackNumber: json['rackNumber'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
      isReserved: json['isReserved'] ?? false,
      reservedBy: json['reservedBy'],
    );
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? category,
    String? rackNumber,
    bool? isAvailable,
    bool? isReserved,
    String? reservedBy,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      category: category ?? this.category,
      rackNumber: rackNumber ?? this.rackNumber,
      isAvailable: isAvailable ?? this.isAvailable,
      isReserved: isReserved ?? this.isReserved,
      reservedBy: reservedBy ?? this.reservedBy,
    );
  }
}