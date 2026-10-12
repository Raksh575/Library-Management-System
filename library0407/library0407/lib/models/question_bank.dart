class QuestionBank {
  final String id;
  final String title;
  final String subject;
  final String semester;
  final String year;
  final String fileUrl;
  final String type; // 'online' or 'offline'
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'semester': semester,
      'year': year,
      'fileUrl': fileUrl,
      'type': type,
      'isActive': isActive,
    };
  }

  factory QuestionBank.fromJson(Map<String, dynamic> json) {
    return QuestionBank(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subject: json['subject'] ?? '',
      semester: json['semester'] ?? '',
      year: json['year'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      type: json['type'] ?? 'offline',
      isActive: json['isActive'] ?? true,
    );
  }

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