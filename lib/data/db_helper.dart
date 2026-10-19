import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Central place that owns the on-device SQLite database used for the
/// User and Book databases (users, books, reviews, marketplace listings,
/// and loan transactions). Swap this file's queries for REST calls to the
/// Java backend (see /backend) if/when you move to a server-backed setup.
class DBHelper {
  DBHelper._internal();
  static final DBHelper instance = DBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'book_worms.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        passwordHash TEXT NOT NULL,
        bio TEXT DEFAULT '',
        avatarColorValue INTEGER NOT NULL,
        role TEXT NOT NULL DEFAULT 'reader',
        isBanned INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        genre TEXT DEFAULT 'General',
        description TEXT DEFAULT '',
        coverColorValue INTEGER NOT NULL,
        addedByUserId INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (addedByUserId) REFERENCES users (id)
      );
    ''');

    await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bookId INTEGER NOT NULL,
        userId INTEGER NOT NULL,
        rating INTEGER NOT NULL,
        text TEXT NOT NULL,
        likeCount INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (bookId) REFERENCES books (id),
        FOREIGN KEY (userId) REFERENCES users (id)
      );
    ''');

    await db.execute('''
      CREATE TABLE review_likes (
        reviewId INTEGER NOT NULL,
        userId INTEGER NOT NULL,
        PRIMARY KEY (reviewId, userId),
        FOREIGN KEY (reviewId) REFERENCES reviews (id),
        FOREIGN KEY (userId) REFERENCES users (id)
      );
    ''');

    await db.execute('''
      CREATE TABLE listings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bookId INTEGER NOT NULL,
        ownerUserId INTEGER NOT NULL,
        type TEXT NOT NULL,
        price REAL,
        condition TEXT NOT NULL DEFAULT 'good',
        status TEXT NOT NULL DEFAULT 'available',
        note TEXT DEFAULT '',
        createdAt TEXT NOT NULL,
        FOREIGN KEY (bookId) REFERENCES books (id),
        FOREIGN KEY (ownerUserId) REFERENCES users (id)
      );
    ''');

    await db.execute('''
      CREATE TABLE loans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        listingId INTEGER NOT NULL,
        bookId INTEGER NOT NULL,
        ownerUserId INTEGER NOT NULL,
        borrowerUserId INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'requested',
        requestedAt TEXT NOT NULL,
        dueDate TEXT,
        returnedAt TEXT,
        FOREIGN KEY (listingId) REFERENCES listings (id),
        FOREIGN KEY (bookId) REFERENCES books (id),
        FOREIGN KEY (ownerUserId) REFERENCES users (id),
        FOREIGN KEY (borrowerUserId) REFERENCES users (id)
      );
    ''');
  }

  /// Wipes all app data. Handy during development or for a "reset demo data"
  /// option in the admin panel.
  Future<void> resetAll() async {
    final db = await database;
    await db.delete('loans');
    await db.delete('listings');
    await db.delete('review_likes');
    await db.delete('reviews');
    await db.delete('books');
    await db.delete('users');
  }
}
