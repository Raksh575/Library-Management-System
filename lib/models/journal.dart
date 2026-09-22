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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'publisher': publisher,
      'category': category,
      'issn': issn,
      'isActive': isActive,
    };
  }

  factory Journal.fromJson(Map<String, dynamic> json) {
    return Journal(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      publisher: json['publisher'] ?? '',
      category: json['category'] ?? '',
      issn: json['issn'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

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