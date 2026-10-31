import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../api_config.dart';
import '../../models/user.dart';

class UserRepository {
  String get _base => '${ApiConfig.baseUrl}/users';
  String get _loginUrl => '${ApiConfig.baseUrl}/auth/login';
  String get _registerUrl => '${ApiConfig.baseUrl}/auth/register';

  String hashPassword(String plain) {
    return sha256.convert(utf8.encode(plain)).toString();
  }

  Future<AppUser?> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.toLowerCase().trim();
    final hashedPassword = hashPassword(password);

    final res = await ApiConfig.client.post(
      Uri.parse(_loginUrl),
      headers: ApiConfig.headers,
      body: jsonEncode({
        'email': cleanEmail,
        'password': password,
        'passwordHash': hashedPassword,
      }),
    );

    if (res.statusCode == 200 && res.body.isNotEmpty) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final userMap = data.containsKey('user') && data['user'] is Map<String, dynamic>
          ? data['user'] as Map<String, dynamic>
          : data;
      return AppUser.fromMap(userMap);
    }
    return null;
  }

  Future<AppUser?> findByEmail(String email) async {
    final cleanEmail = email.toLowerCase().trim();
    final all = await getAllUsers();
    for (final u in all) {
      if (u.email.toLowerCase().trim() == cleanEmail) return u;
    }
    return null;
  }

  Future<AppUser?> findById(int id) async {
    final res = await ApiConfig.client.get(
      Uri.parse('$_base/$id'),
      headers: ApiConfig.headers,
    );
    if (res.statusCode == 200 && res.body.isNotEmpty) {
      return AppUser.fromMap(jsonDecode(res.body) as Map<String, dynamic>);
    }
    return null;
  }

  Future<AppUser?> register({
    required String name,
    required String email,
    required String password,
    required int avatarColorValue,
  }) async {
    final cleanEmail = email.toLowerCase().trim();
    final hashedPassword = hashPassword(password);

    final user = AppUser(
      name: name.trim(),
      email: cleanEmail,
      passwordHash: hashedPassword,
      avatarColorValue: avatarColorValue,
      role: UserRole.reader,
    );

    final payload = user.toMap()
      ..remove('id')
      ..['password'] = password; // Included in case the backend hashes raw password

    final res = await ApiConfig.client.post(
      Uri.parse(_registerUrl),
      headers: ApiConfig.headers,
      body: jsonEncode(payload),
    );

    if ((res.statusCode == 200 || res.statusCode == 201) && res.body.isNotEmpty) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final userMap = data.containsKey('user') && data['user'] is Map<String, dynamic>
          ? data['user'] as Map<String, dynamic>
          : data;
      return AppUser.fromMap(userMap);
    }
    return null;
  }

  Future<List<AppUser>> getAllUsers() async {
    final res = await ApiConfig.client.get(
      Uri.parse(_base),
      headers: ApiConfig.headers,
    );
    if (res.statusCode == 200) {
      final List<dynamic> list = jsonDecode(res.body);
      final users = list.map((e) => AppUser.fromMap(e as Map<String, dynamic>)).toList();
      users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return users;
    }
    return [];
  }

  Future<void> setBanned(int userId, bool banned) async {
    final existing = await findById(userId);
    if (existing == null) return;
    final updated = existing.copyWith(isBanned: banned);
    await ApiConfig.client.put(
      Uri.parse('$_base/$userId'),
      headers: ApiConfig.headers,
      body: jsonEncode(updated.toMap()),
    );
  }

  Future<void> setRole(int userId, UserRole role) async {
    final existing = await findById(userId);
    if (existing == null) return;
    final updated = existing.copyWith(role: role);
    await ApiConfig.client.put(
      Uri.parse('$_base/$userId'),
      headers: ApiConfig.headers,
      body: jsonEncode(updated.toMap()),
    );
  }
Future<AppUser?> updateProfile(int userId, {String? name, String? bio}) async {
    final payload = <String, dynamic>{
      if (name != null) 'name': name.trim(),
      if (bio != null) 'bio': bio.trim(),
    };

    final res = await ApiConfig.client.patch(
      Uri.parse('$_base/$userId/profile'),
      headers: ApiConfig.headers,
      body: jsonEncode(payload),
    );

    if (res.statusCode == 200 && res.body.isNotEmpty) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final userMap = data.containsKey('user') && data['user'] is Map<String, dynamic>
          ? data['user'] as Map<String, dynamic>
          : data;
      return AppUser.fromMap(userMap);
    }
    return null;
  }

  Future<int> countUsers() async {
    final users = await getAllUsers();
    return users.length;
  }
}