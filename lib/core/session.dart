
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_user.dart';

/// Holds the logged-in user and tokens.
/// With "Remember Me" the tokens are also saved to disk so the app logs in
/// automatically next time. Without it they live in memory only.
///
/// NOTE: shared_preferences is a plain-text file. Before shipping to real
/// users, swap the three storage calls below for flutter_secure_storage.
class Session {
  Session._();
  static final Session instance = Session._();

  static const _kAccess = 'accessToken';
  static const _kRefresh = 'refreshToken';
  static const _kUser = 'user';

  String? accessToken;
  String? refreshToken;
  AuthUser? user;
  bool _persist = false;

  bool get isLoggedIn => accessToken != null;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    accessToken = p.getString(_kAccess);
    refreshToken = p.getString(_kRefresh);
    final raw = p.getString(_kUser);
    if (raw != null) {
      try {
        user = AuthUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        user = null;
      }
    }
    _persist = accessToken != null;
  }

  Future<void> set({
    required String access,
    String? refresh,
    AuthUser? user,
    bool? remember,
  }) async {
    accessToken = access;
    if (refresh != null) refreshToken = refresh;
    if (user != null) this.user = user;
    if (remember != null) _persist = remember;
    await _save();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    if (!_persist) {
      await p.remove(_kAccess);
      await p.remove(_kRefresh);
      await p.remove(_kUser);
      return;
    }
    await p.setString(_kAccess, accessToken ?? '');
    if (refreshToken != null) await p.setString(_kRefresh, refreshToken!);
    if (user != null) await p.setString(_kUser, jsonEncode(user!.toJson()));
  }

  Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
    user = null;
    _persist = false;
    final p = await SharedPreferences.getInstance();
    await p.remove(_kAccess);
    await p.remove(_kRefresh);
    await p.remove(_kUser);
  }
}
