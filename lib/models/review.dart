class Review {
  final int? id;
  final int bookId;
  final int userId;
  final int rating; // 1-5
  final String text;
  final int likeCount;
  final DateTime createdAt;

  Review({
    this.id,
    required this.bookId,
    required this.userId,
    required this.rating,
    required this.text,
    this.likeCount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'userId': userId,
      'rating': rating,
      'text': text,
      'likeCount': likeCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] as int?,
      bookId: map['bookId'] as int,
      userId: map['userId'] as int,
      rating: map['rating'] as int,
      text: map['text'] as String,
      likeCount: map['likeCount'] as int? ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
