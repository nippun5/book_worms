import '../db_helper.dart';
import '../../models/book_listing.dart';

class ListingRepository {
  final _dbHelper = DBHelper.instance;

  Future<BookListing> addListing(BookListing listing) async {
    final db = await _dbHelper.database;
    final id = await db.insert('listings', listing.toMap()..remove('id'));
    return BookListing(
      id: id,
      bookId: listing.bookId,
      ownerUserId: listing.ownerUserId,
      type: listing.type,
      price: listing.price,
      condition: listing.condition,
      status: listing.status,
      note: listing.note,
      createdAt: listing.createdAt,
    );
  }

  Future<List<BookListing>> getAll({ListingType? type}) async {
    final db = await _dbHelper.database;
    final rows = type == null
        ? await db.query('listings', orderBy: 'createdAt DESC')
        : await db.query('listings', where: 'type = ?', whereArgs: [type.name], orderBy: 'createdAt DESC');
    return rows.map(BookListing.fromMap).toList();
  }

  Future<List<BookListing>> getByOwner(int ownerUserId) async {
    final db = await _dbHelper.database;
    final rows =
        await db.query('listings', where: 'ownerUserId = ?', whereArgs: [ownerUserId], orderBy: 'createdAt DESC');
    return rows.map(BookListing.fromMap).toList();
  }

  Future<List<BookListing>> getByBook(int bookId) async {
    final db = await _dbHelper.database;
    final rows = await db.query('listings', where: 'bookId = ?', whereArgs: [bookId], orderBy: 'createdAt DESC');
    return rows.map(BookListing.fromMap).toList();
  }

  Future<BookListing?> findById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query('listings', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return BookListing.fromMap(rows.first);
  }

  Future<void> updateStatus(int listingId, ListingStatus status) async {
    final db = await _dbHelper.database;
    await db.update('listings', {'status': status.name}, where: 'id = ?', whereArgs: [listingId]);
  }

  Future<int> countAll() async {
    final db = await _dbHelper.database;
    final r = await db.rawQuery('SELECT COUNT(*) AS c FROM listings');
    return (r.first['c'] as int?) ?? 0;
  }

  /// Removes a listing and any loan history attached to it.
  Future<void> deleteListing(int id) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete('loans', where: 'listingId = ?', whereArgs: [id]);
      await txn.delete('listings', where: 'id = ?', whereArgs: [id]);
    });
  }
}
