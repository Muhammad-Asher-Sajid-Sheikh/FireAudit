import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'session.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  /// Set when login is refused because the account is PENDING / REJECTED / SUSPENDED.
  final String? accountStatus;

  const ApiException(this.message, {this.statusCode, this.accountStatus});

  bool get isAuthError => statusCode == 401;

  @override
  String toString() => message;
}

class ApiResponse {
  final Map<String, dynamic> json;
  final Map<String, String> headers;
  const ApiResponse(this.json, this.headers);
}

/// Thin wrapper over `http` that:
///  - adds the Bearer token,
///  - on a 401 refreshes the access token once and retries,
///  - turns every failure into an [ApiException] with a readable message.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  final http.Client _http = http.Client();
  Future<bool>? _refreshing;

  /// Pulls a cookie value out of a Set-Cookie header.
  static String? cookieValue(String? setCookieHeader, String name) {
    if (setCookieHeader == null) return null;
    final m = RegExp('$name=([^;,\\s]+)').firstMatch(setCookieHeader);
    return m?.group(1);
  }

  Future<ApiResponse> send(
      String method,
      String path, {
        Map<String, dynamic>? body,
        bool auth = true,
        bool retryOn401 = true,
        Map<String, String>? extraHeaders,
      }) async {
    var res = await _raw(method, path,
        body: body, auth: auth, extraHeaders: extraHeaders);
    if (res.statusCode == 401 && auth && retryOn401) {
      if (await _refresh()) {
        res = await _raw(method, path,
            body: body, auth: auth, extraHeaders: extraHeaders);
      }
    }
    return _handle(res);
  }

  Future<http.Response> _raw(
      String method,
      String path, {
        Map<String, dynamic>? body,
        bool auth = true,
        Map<String, String>? extraHeaders,
      }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = Session.instance.accessToken;
    if (auth && token != null) headers['Authorization'] = 'Bearer $token';
    if (extraHeaders != null) headers.addAll(extraHeaders);

    final req = http.Request(method, Uri.parse('${ApiConfig.baseUrl}$path'))
      ..headers.addAll(headers);
    if (body != null) req.body = jsonEncode(body);

    try {
      final streamed = await _http.send(req).timeout(const Duration(seconds: 20));
      return await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw const ApiException('The server took too long to respond. Please try again.');
    } on SocketException {
      throw ApiException(
          'Cannot reach the server at ${ApiConfig.baseUrl}. Make sure the backend is running.');
    } on http.ClientException {
      throw ApiException(
          'Cannot reach the server at ${ApiConfig.baseUrl}. Make sure the backend is running.');
    }
  }

  ApiResponse _handle(http.Response res) {
    var json = <String, dynamic>{};
    try {
      final d = jsonDecode(res.body);
      if (d is Map<String, dynamic>) json = d;
    } catch (_) {}

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return ApiResponse(json, res.headers);
    }

    final status = json['status'];
    throw ApiException(
      json['message']?.toString() ?? 'Request failed (${res.statusCode}).',
      statusCode: res.statusCode,
      accountStatus: status is String ? status : null,
    );
  }

  /// One refresh at a time, even if several requests fail together.
  /// The backend reads the refresh token from a cookie and also wants the
  /// (expired) access token in the Authorization header.
  Future<bool> _refresh() =>
      _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);

  Future<bool> _doRefresh() async {
    final s = Session.instance;
    if (s.refreshToken == null || s.accessToken == null) return false;
    try {
      final res = await _raw(
        'POST',
        '/api/auth/refresh',
        extraHeaders: {'Cookie': 'refreshtoken=${s.refreshToken}'},
      );
      if (res.statusCode != 200) return false;
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final access = json['accesstoken'];
      if (access is! String) return false;
      final newRefresh = cookieValue(res.headers['set-cookie'], 'refreshtoken');
      await s.set(access: access, refresh: newRefresh);
      return true;
    } catch (_) {
      return false;
    }
  }
}
