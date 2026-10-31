import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import '../../models/book.dart';

class BookRepository {
  String get _base => '${ApiConfig.baseUrl}/books';

  Future<Book> addBook(Book book) async {
    final payload = book.toMap()..remove('id');
    final res = await http.post(
      Uri.parse(_base),
      headers: ApiConfig.headers,
      body: jsonEncode(payload),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return Book.fromMap(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to add book: ${res.statusCode}${res.body}');
  }

  Future<Book?> findById(int id) async {
    final res = await http.get(Uri.parse('$_base/$id'), headers: ApiConfig.headers);
    if (res.statusCode == 200 && res.body.isNotEmpty) {
      return Book.fromMap(jsonDecode(res.body) as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<Book>> getAllBooks() async {
    final res = await http.get(Uri.parse(_base), headers: ApiConfig.headers);
    if (res.statusCode == 200) {
      final List<dynamic> list = jsonDecode(res.body);
      final books = list.map((e) => Book.fromMap(e as Map<String, dynamic>)).toList();
      books.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      return books;
    }
    throw Exception('Failed to load books: ${res.statusCode}');
  }

  Future<List<Book>> search(String query) async {
    // Try server-side search param first; also filter client-side to guarantee accuracy
    final uri = Uri.parse(_base).replace(queryParameters: {'q': query, 'query': query});
    final res = await http.get(uri, headers: ApiConfig.headers);
    if (res.statusCode == 200) {
      final List<dynamic> list = jsonDecode(res.body);
      final q = query.toLowerCase();
      final books = list
          .map((e) => Book.fromMap(e as Map<String, dynamic>))
          .where((b) => b.title.toLowerCase().contains(q) || b.author.toLowerCase().contains(q))
          .toList();
      books.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      return books;
    }
    return [];
  }

  Future<int> countAll() async {
    final books = await getAllBooks();
    return books.length;
  }

  Future<void> deleteBookCascade(int bookId) async {
    final res = await http.delete(Uri.parse('$_base/$bookId'), headers: ApiConfig.headers);
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to delete book: ${res.statusCode}');
    }
  }
}