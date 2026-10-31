import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import '../../models/review.dart';

class ReviewRepository {
  String get _base => '${ApiConfig.baseUrl}/reviews';

  // Local fallback set in case backend doesn't expose a /likes endpoint
  static final Map<int, Set<int>> _localLikesCache = {};

  Future<Review> addReview(Review review) async {
    final payload = review.toMap()..remove('id');
    final res = await http.post(
      Uri.parse(_base),
      headers: ApiConfig.headers,
      body: jsonEncode(payload),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return Review.fromMap(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to add review: ${res.statusCode} ${res.body}');
  }

  Future<List<Review>> getReviewsForBook(int bookId) async {
    final uri = Uri.parse(_base).replace(queryParameters: {'bookId': '$bookId'});
    final res = await http.get(uri, headers: ApiConfig.headers);
    if (res.statusCode == 200) {
      final List<dynamic> list = jsonDecode(res.body);
      final reviews = list
          .map((e) => Review.fromMap(e as Map<String, dynamic>))
          .where((r) => r.bookId == bookId)
          .toList();
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reviews;
    }
    return [];
  }

  Future<List<Review>> getRecentReviews({int limit = 100}) async {
    final all = await getAllReviews();
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all.take(limit).toList();
  }

  Future<List<Review>> getTrendingReviews({int limit = 100}) async {
    final all = await getAllReviews();
    all.sort((a, b) {
      final cmp = b.likeCount.compareTo(a.likeCount);
      return cmp != 0 ? cmp : b.createdAt.compareTo(a.createdAt);
    });
    return all.take(limit).toList();
  }

  Future<List<Review>> getReviewsByUser(int userId) async {
    final uri = Uri.parse(_base).replace(queryParameters: {'userId': '$userId'});
    final res = await http.get(uri, headers: ApiConfig.headers);
    if (res.statusCode == 200) {
      final List<dynamic> list = jsonDecode(res.body);
      final reviews = list
          .map((e) => Review.fromMap(e as Map<String, dynamic>))
          .where((r) => r.userId == userId)
          .toList();
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reviews;
    }
    return [];
  }

  Future<List<Review>> getAllReviews() async {
    final res = await http.get(Uri.parse(_base), headers: ApiConfig.headers);
    if (res.statusCode == 200) {
      final List<dynamic> list = jsonDecode(res.body);
      final reviews = list.map((e) => Review.fromMap(e as Map<String, dynamic>)).toList();
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reviews;
    }
    return [];
  }

  Future<Set<int>> getLikedReviewIds(int userId) async {
    final uri = Uri.parse('$_base/liked').replace(queryParameters: {'userId': '$userId'});
    final res = await http.get(uri, headers: ApiConfig.headers);
    if (res.statusCode == 200) {
      final List<dynamic> list = jsonDecode(res.body);
      return list.map((e) => (e as num).toInt()).toSet();
    }
    return _localLikesCache[userId] ?? <int>{};
  }

  Future<bool> toggleLike(int reviewId, int userId) async {
    final uri = Uri.parse('$_base/$reviewId/like').replace(queryParameters: {'userId': '$userId'});
    final res = await http.post(
      uri,
      headers: ApiConfig.headers,
      body: jsonEncode({'userId': userId}),
    );
    if (res.statusCode == 200 && res.body.isNotEmpty) {
      final decoded = jsonDecode(res.body);
      if (decoded is bool) return decoded;
      if (decoded is Map && decoded.containsKey('liked')) return decoded['liked'] as bool;
    }

    // Fallback if backend only supports PUT on /api/reviews/{id}
    final userLikes = _localLikesCache.putIfAbsent(userId, () => <int>{});
    final isNowLiked = !userLikes.contains(reviewId);
    if (isNowLiked) {
      userLikes.add(reviewId);
    } else {
      userLikes.remove(reviewId);
    }
    return isNowLiked;
  }

  Future<void> deleteReview(int reviewId) async {
    final res = await http.delete(Uri.parse('$_base/$reviewId'), headers: ApiConfig.headers);
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to delete review: ${res.statusCode}');
    }
  }

  Future<int> countAll() async {
    final all = await getAllReviews();
    return all.length;
  }
}