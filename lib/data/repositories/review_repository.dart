import '../db_helper.dart';
import '../../models/review.dart';

class ReviewRepository {
  final _dbHelper = DBHelper.instance;

  Future<Review> addReview(Review review) async {
    final db = await _dbHelper.database;
    final id = await db.insert('reviews', review.toMap()..remove('id'));
    return Review(
      id: id,
      bookId: review.bookId,
      userId: review.userId,
      rating: review.rating,
      text: review.text,
      likeCount: review.likeCount,
      createdAt: review.createdAt,
    );
  }

  Future<List<Review>> getReviewsForBook(int bookId) async {
    final db = await _dbHelper.database;
    final rows = await db.query('reviews', where: 'bookId = ?', whereArgs: [bookId], orderBy: 'createdAt DESC');
    return rows.map(Review.fromMap).toList();
  }

  /// Newest reviews first — powers the "New" feed tab.
  Future<List<Review>> getRecentReviews({int limit = 100}) async {
    final db = await _dbHelper.database;
    final rows = await db.query('reviews', orderBy: 'createdAt DESC', limit: limit);
    return rows.map(Review.fromMap).toList();
  }

  /// Most-liked first — powers the "Trending" feed tab.
  Future<List<Review>> getTrendingReviews({int limit = 100}) async {
    final db = await _dbHelper.database;
    final rows = await db.query('reviews', orderBy: 'likeCount DESC, createdAt DESC', limit: limit);
    return rows.map(Review.fromMap).toList();
  }

  Future<List<Review>> getReviewsByUser(int userId) async {
    final db = await _dbHelper.database;
    final rows = await db.query('reviews', where: 'userId = ?', whereArgs: [userId], orderBy: 'createdAt DESC');
    return rows.map(Review.fromMap).toList();
  }

  Future<List<Review>> getAllReviews() async {
    final db = await _dbHelper.database;
    final rows = await db.query('reviews', orderBy: 'createdAt DESC');
    return rows.map(Review.fromMap).toList();
  }

  /// Ids of reviews the given user has liked.
  Future<Set<int>> getLikedReviewIds(int userId) async {
    final db = await _dbHelper.database;
    final rows = await db.query('review_likes', columns: ['reviewId'], where: 'userId = ?', whereArgs: [userId]);
    return rows.map((r) => r['reviewId'] as int).toSet();
  }

  /// Toggles a like. Returns true if the review is now liked by the user.
  Future<bool> toggleLike(int reviewId, int userId) async {
    final db = await _dbHelper.database;
    return db.transaction((txn) async {
      final existing = await txn.query('review_likes',
          where: 'reviewId = ? AND userId = ?', whereArgs: [reviewId, userId]);
      if (existing.isEmpty) {
        await txn.insert('review_likes', {'reviewId': reviewId, 'userId': userId});
        await txn.rawUpdate('UPDATE reviews SET likeCount = likeCount + 1 WHERE id = ?', [reviewId]);
        return true;
      } else {
        await txn.delete('review_likes', where: 'reviewId = ? AND userId = ?', whereArgs: [reviewId, userId]);
        await txn.rawUpdate('UPDATE reviews SET likeCount = MAX(likeCount - 1, 0) WHERE id = ?', [reviewId]);
        return false;
      }
    });
  }

  Future<void> deleteReview(int reviewId) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete('review_likes', where: 'reviewId = ?', whereArgs: [reviewId]);
      await txn.delete('reviews', where: 'id = ?', whereArgs: [reviewId]);
    });
  }

  Future<int> countAll() async {
    final db = await _dbHelper.database;
    final r = await db.rawQuery('SELECT COUNT(*) AS c FROM reviews');
    return (r.first['c'] as int?) ?? 0;
  }
}
