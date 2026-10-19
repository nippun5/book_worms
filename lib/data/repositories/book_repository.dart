import '../db_helper.dart';
import '../../models/book.dart';

class BookRepository {
  final _dbHelper = DBHelper.instance;

  Future<Book> addBook(Book book) async {
    final db = await _dbHelper.database;
    final id = await db.insert('books', book.toMap()..remove('id'));
    return Book(
      id: id,
      title: book.title,
      author: book.author,
      genre: book.genre,
      description: book.description,
      coverColorValue: book.coverColorValue,
      addedByUserId: book.addedByUserId,
      createdAt: book.createdAt,
    );
  }

  Future<Book?> findById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query('books', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Book.fromMap(rows.first);
  }

  Future<List<Book>> getAllBooks() async {
    final db = await _dbHelper.database;
    final rows = await db.query('books', orderBy: 'title COLLATE NOCASE ASC');
    return rows.map(Book.fromMap).toList();
  }

  Future<List<Book>> search(String query) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'books',
      where: 'title LIKE ? OR author LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'title COLLATE NOCASE ASC',
    );
    return rows.map(Book.fromMap).toList();
  }

  Future<int> countAll() async {
    final db = await _dbHelper.database;
    final r = await db.rawQuery('SELECT COUNT(*) AS c FROM books');
    return (r.first['c'] as int?) ?? 0;
  }

  /// Admin action: removes a book and everything attached to it
  /// (reviews, likes, listings, loans).
  Future<void> deleteBookCascade(int bookId) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.rawDelete(
          'DELETE FROM review_likes WHERE reviewId IN (SELECT id FROM reviews WHERE bookId = ?)', [bookId]);
      await txn.delete('reviews', where: 'bookId = ?', whereArgs: [bookId]);
      await txn.delete('loans', where: 'bookId = ?', whereArgs: [bookId]);
      await txn.delete('listings', where: 'bookId = ?', whereArgs: [bookId]);
      await txn.delete('books', where: 'id = ?', whereArgs: [bookId]);
    });
  }
}
