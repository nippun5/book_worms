import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import '../db_helper.dart';
import '../../models/user.dart';

class UserRepository {
  final _dbHelper = DBHelper.instance;

  String hashPassword(String plain) {
    return sha256.convert(utf8.encode(plain)).toString();
  }

  Future<AppUser?> findByEmail(String email) async {
    final db = await _dbHelper.database;
    final rows = await db.query('users', where: 'email = ?', whereArgs: [email.toLowerCase().trim()]);
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<AppUser?> findById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  /// Registers a new reader account. Returns null if the email is taken.
  Future<AppUser?> register({
    required String name,
    required String email,
    required String password,
    required int avatarColorValue,
  }) async {
    final existing = await findByEmail(email);
    if (existing != null) return null;

    final db = await _dbHelper.database;
    final user = AppUser(
      name: name.trim(),
      email: email.toLowerCase().trim(),
      passwordHash: hashPassword(password),
      avatarColorValue: avatarColorValue,
      role: UserRole.reader,
    );
    final id = await db.insert('users', user.toMap()..remove('id'));
    return user.copyWith(id: id);
  }

  /// Returns the user if credentials are valid, otherwise null.
  Future<AppUser?> login({required String email, required String password}) async {
    final user = await findByEmail(email);
    if (user == null) return null;
    if (user.passwordHash != hashPassword(password)) return null;
    return user;
  }

  Future<List<AppUser>> getAllUsers() async {
    final db = await _dbHelper.database;
    final rows = await db.query('users', orderBy: 'createdAt DESC');
    return rows.map(AppUser.fromMap).toList();
  }

  Future<void> setBanned(int userId, bool banned) async {
    final db = await _dbHelper.database;
    await db.update('users', {'isBanned': banned ? 1 : 0}, where: 'id = ?', whereArgs: [userId]);
  }

  Future<void> setRole(int userId, UserRole role) async {
    final db = await _dbHelper.database;
    await db.update('users', {'role': role.name}, where: 'id = ?', whereArgs: [userId]);
  }

  Future<void> updateProfile(int userId, {String? name, String? bio}) async {
    final db = await _dbHelper.database;
    final values = <String, dynamic>{};
    if (name != null) values['name'] = name;
    if (bio != null) values['bio'] = bio;
    if (values.isEmpty) return;
    await db.update('users', values, where: 'id = ?', whereArgs: [userId]);
  }

  Future<int> countUsers() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as c FROM users');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
