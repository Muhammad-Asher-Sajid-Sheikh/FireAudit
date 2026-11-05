import '../core/api_client.dart';
import '../core/session.dart';
import '../models/auth_user.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _api = ApiClient.instance;

  /// POST /api/auth/login
  Future<AuthUser> login(String email, String password,
      {required bool remember}) async {
    final r = await _api.send(
      'POST',
      '/api/auth/login',
      body: {'email': email.trim(), 'password': password},
      auth: false,
    );
    final access = r.json['accesstoken'];
    final userJson = r.json['user'];
    if (access is! String || userJson is! Map<String, dynamic>) {
      throw const ApiException('Unexpected response from the server.');
    }
    final user = AuthUser.fromJson(userJson);
    final refresh = ApiClient.cookieValue(r.headers['set-cookie'], 'refreshtoken');
    await Session.instance
        .set(access: access, refresh: refresh, user: user, remember: remember);
    return user;
  }

  /// POST /api/auth/register  -> returns the server's message
  /// (new accounts are PENDING until a MANAGEMENT user approves them).
  Future<String> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
  }) async {
    final r = await _api.send(
      'POST',
      '/api/auth/register',
      body: {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'confirmPassword': confirmPassword,
        'role': role,
      },
      auth: false,
    );
    return r.json['message']?.toString() ?? 'Registration successful.';
  }

  /// Used by the splash screen. True only if a saved session is still valid
  /// (the access token is refreshed automatically if it has expired).
  Future<bool> tryAutoLogin() async {
    final s = Session.instance;
    try {
      await s.load();
      if (s.accessToken == null) return false;

      final r = await _api.send('GET', '/api/auth/profile');
      final u = r.json['user'];
      if (u is! Map<String, dynamic>) return false;

      final user = AuthUser.fromJson(u);
      if (user.status != null && user.status != 'APPROVED') {
        await s.clear();
        return false;
      }
      await s.set(access: s.accessToken!, user: user);
      return true;
    } on ApiException catch (e) {
      // Only drop the saved session if the server rejected it.
      // If the backend is just offline, keep it for next time.
      if (e.statusCode == 401 || e.statusCode == 403) await s.clear();
      return false;
    } catch (_) {
      return false;
    }
  }

  /// POST /api/auth/logout (best effort), then forget everything locally.
  Future<void> logout() async {
    final s = Session.instance;
    try {
      await _api.send(
        'POST',
        '/api/auth/logout',
        retryOn401: false,
        extraHeaders:
            s.refreshToken == null ? null : {'Cookie': 'refreshtoken=${s.refreshToken}'},
      );
    } catch (_) {}
    await s.clear();
  }
}
