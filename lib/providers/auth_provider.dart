import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_colors.dart';
import '../data/repositories/user_repository.dart';
import '../data/seed_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  static const _sessionKey = 'session_user_id';

  final _users = UserRepository();

  AppUser? _user;
  bool _initializing = true;
  bool _busy = false;
  String? _error;

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.role == UserRole.admin;
  bool get initializing => _initializing;
  bool get busy => _busy;
  String? get error => _error;

  /// Called once at startup: seeds demo data and restores the saved session.
  Future<void> init() async {
    await SeedService().seedIfNeeded();
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getInt(_sessionKey);
    if (savedId != null) {
      final u = await _users.findById(savedId);
      if (u != null && !u.isBanned) {
        _user = u;
      } else {
        await prefs.remove(_sessionKey);
      }
    }
    _initializing = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      final u = await _users.login(email: email, password: password);
      if (u == null) {
        _error = 'Incorrect email or password.';
        return false;
      }
      if (u.isBanned) {
        _error = 'This account has been suspended. Contact support if you think this is a mistake.';
        return false;
      }
      _user = u;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_sessionKey, u.id!);
      return true;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> register({required String name, required String email, required String password}) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      final color = AppColors.accentFor(email.hashCode).value;
      final u = await _users.register(name: name, email: email, password: password, avatarColorValue: color);
      if (u == null) {
        _error = 'An account with this email already exists.';
        return false;
      }
      _user = u;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_sessionKey, u.id!);
      return true;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    _user = null;
    notifyListeners();
  }

  /// Re-reads the signed-in user from the database (e.g. after admin changes).
  Future<void> refresh() async {
    if (_user == null) return;
    final u = await _users.findById(_user!.id!);
    if (u == null || u.isBanned) {
      await logout();
      return;
    }
    _user = u;
    notifyListeners();
  }

  Future<void> updateProfile({String? name, String? bio}) async {
    if (_user == null) return;
    await _users.updateProfile(_user!.id!, name: name?.trim(), bio: bio?.trim());
    await refresh();
  }
}
