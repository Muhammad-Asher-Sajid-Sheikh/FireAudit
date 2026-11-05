class AuthUser {
  final String id;
  final String name;
  final String email;
  final String role; // MANAGEMENT | PRODUCTION | MERCHANDISE | MARKETING
  final String? status; // only returned by /api/auth/profile

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.status,
  });

  factory AuthUser.fromJson(Map<String, dynamic> j) => AuthUser(
        id: j['id'].toString(),
        name: (j['name'] ?? '').toString(),
        email: (j['email'] ?? '').toString(),
        role: (j['role'] ?? '').toString(),
        status: j['status']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'status': status,
      };

  /// "PRODUCTION" -> "Production"
  String get roleLabel => role.isEmpty
      ? ''
      : role[0].toUpperCase() + role.substring(1).toLowerCase();
}
