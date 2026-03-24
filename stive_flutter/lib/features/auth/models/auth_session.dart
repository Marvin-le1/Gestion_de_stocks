class AuthSession {
  const AuthSession({
    required this.token,
    required this.email,
    required this.nom,
    required this.role,
  });

  final String token;
  final String email;
  final String nom;
  final String role;

  bool get isAdmin => role.toUpperCase() == 'ADMIN' || role.toUpperCase() == 'ROLE_ADMIN';
  bool get isClient => role.toUpperCase() == 'CLIENT' || role.toUpperCase() == 'ROLE_CLIENT';

  Map<String, String> toStorage() {
    return {
      'token': token,
      'email': email,
      'nom': nom,
      'role': role,
    };
  }

  static AuthSession? fromStorage(Map<String, Object?> data) {
    final token = (data['token'] as String?)?.trim() ?? '';
    final email = (data['email'] as String?)?.trim() ?? '';
    final nom = (data['nom'] as String?)?.trim() ?? '';
    final role = (data['role'] as String?)?.trim() ?? '';

    if (token.isEmpty || email.isEmpty || role.isEmpty) {
      return null;
    }

    return AuthSession(token: token, email: email, nom: nom, role: role);
  }
}
