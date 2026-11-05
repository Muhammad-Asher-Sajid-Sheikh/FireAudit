class ApiConfig {
  ApiConfig._();

  /// Backend address. To point the app at another machine, run with:
  ///   flutter run -d windows --dart-define=API_BASE_URL=http://192.168.1.10:3000
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
}
