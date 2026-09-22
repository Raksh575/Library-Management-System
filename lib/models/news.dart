class News {
  final String id;
  final String title;
  final String description;
  final String content;
  final String imageUrl;
  final bool isSaved;
  final DateTime date;
  final int likes;
  final int comments;
  final bool isActive;

  News({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.imageUrl,
    required this.isSaved,
    required this.date,
    required this.likes,
    required this.comments,
    required this.isActive,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'content': content,
    'imageUrl': imageUrl,
    'isSaved': isSaved,
    'date': date.toIso8601String(),
    'likes': likes,
    'comments': comments,
    'isActive': isActive,
  };

  factory News.fromJson(Map<String, dynamic> json) => News(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    content: json['content'],
    imageUrl: json['imageUrl'],
    isSaved: json['isSaved'],
    date: DateTime.parse(json['date']),
    likes: json['likes'],
    comments: json['comments'],
    isActive: json['isActive'],
  );

  News copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? imageUrl,
    bool? isSaved,
    DateTime? date,
    int? likes,
    int? comments,
    bool? isActive,
  }) {
    return News(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      isSaved: isSaved ?? this.isSaved,
      date: date ?? this.date,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isActive: isActive ?? this.isActive,
    );
  }
}
