class Book {
  final int? id;
  final String title;
  final String author;
  final String genre;
  final String description;
  final int coverColorValue;
  final int addedByUserId;
  final DateTime createdAt;

  Book({
    this.id,
    required this.title,
    required this.author,
    this.genre = 'General',
    this.description = '',
    required this.coverColorValue,
    required this.addedByUserId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Book copyWith({
    String? title,
    String? author,
    String? genre,
    String? description,
    int? coverColorValue,
  }) {
    return Book(
      id: id,
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      description: description ?? this.description,
      coverColorValue: coverColorValue ?? this.coverColorValue,
      addedByUserId: addedByUserId,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'genre': genre,
      'description': description,
      'coverColorValue': coverColorValue,
      'addedByUserId': addedByUserId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as int?,
      title: map['title'] as String,
      author: map['author'] as String,
      genre: map['genre'] as String? ?? 'General',
      description: map['description'] as String? ?? '',
      coverColorValue: map['coverColorValue'] as int,
      addedByUserId: map['addedByUserId'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
