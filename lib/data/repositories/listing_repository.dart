import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import '../../models/book_listing.dart';

class ListingRepository {
  String get _base => '${ApiConfig.baseUrl}/listings';

  Future<BookListing> addListing(BookListing listing) async {
    final payload = listing.toMap()..remove('id');
    final res = await http.post(
      Uri.parse(_base),
      headers: ApiConfig.headers,
      body: jsonEncode(payload),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return BookListing.fromMap(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to add listing: ${res.statusCode}${res.body}');
  }

  Future<List<BookListing>> getAll({ListingType? type}) async {
    final uri = type == null
    ? Uri.parse(_base)
    : Uri.parse(_base).replace(queryParameters: {'type': type.name.toUpperCase()});
    final res = await http.get(uri, headers: ApiConfig.headers);
    if (res.statusCode == 200) {
      final List<dynamic> list = jsonDecode(res.body);
      var listings = list.map((e) => BookListing.fromMap(e as Map<String, dynamic>)).toList();
      if (type != null) {
        listings = listings.where((l) => l.type == type).toList();
      }
      listings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return listings;
    }
    throw Exception('Failed to fetch listings: ${res.statusCode}');
  }

  Future<List<BookListing>> getByOwner(int ownerUserId) async {
    final uri = Uri.parse(_base).replace(queryParameters: {'ownerUserId': '$ownerUserId'});
    final res = await http.get(uri, headers: ApiConfig.headers);
    if (res.statusCode == 200) {
      final List<dynamic> list = jsonDecode(res.body);
      final listings = list
          .map((e) => BookListing.fromMap(e as Map<String, dynamic>))
          .where((l) => l.ownerUserId == ownerUserId)
          .toList();
      listings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return listings;
    }
    return [];
  }

  Future<List<BookListing>> getByBook(int bookId) async {
    final uri = Uri.parse(_base).replace(queryParameters: {'bookId': '$bookId'});
    final res = await http.get(uri, headers: ApiConfig.headers);
    if (res.statusCode == 200) {
      final List<dynamic> list = jsonDecode(res.body);
      final listings = list
          .map((e) => BookListing.fromMap(e as Map<String, dynamic>))
          .where((l) => l.bookId == bookId)
          .toList();
      listings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return listings;
    }
    return [];
  }

  Future<BookListing?> findById(int id) async {
    final res = await http.get(Uri.parse('$_base/$id'), headers: ApiConfig.headers);
    if (res.statusCode == 200 && res.body.isNotEmpty) {
      return BookListing.fromMap(jsonDecode(res.body) as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateStatus(int listingId, ListingStatus status) async {
    // Attempt PATCH /status first; fallback to full PUT if backend uses standard PUT
    final patchRes = await http.patch(
      Uri.parse('$_base/$listingId/status'),
      headers: ApiConfig.headers,
     body: jsonEncode({'status': status.name.toUpperCase()}),
    );
    if (patchRes.statusCode == 200 || patchRes.statusCode == 204) return;

    final existing = await findById(listingId);
    if (existing != null) {
      final updated = existing.copyWith(status: status);
      await http.put(
        Uri.parse('$_base/$listingId'),
        headers: ApiConfig.headers,
        body: jsonEncode(updated.toMap()),
      );
    }
  }

  Future<int> countAll() async {
    final all = await getAll();
    return all.length;
  }

  Future<void> deleteListing(int id) async {
    final res = await http.delete(Uri.parse('$_base/$id'), headers: ApiConfig.headers);
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to delete listing: ${res.statusCode}');
    }
  }
}