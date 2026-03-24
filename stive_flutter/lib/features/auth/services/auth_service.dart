import '../../../core/network/api_client.dart';
import '../../../core/utils/types.dart';
import '../models/auth_session.dart';

class AuthService {
  AuthService._();

  static Future<AuthSession> login({
    required String email,
    required String motDePasse,
  }) async {
    final data = await ApiClient.post(
      '/auth/login',
      data: {'email': email, 'motDePasse': motDePasse},
    );
    return _parseAuthResponse(data);
  }

  static Future<AuthSession> register({
    required String nom,
    required String email,
    required String motDePasse,
  }) async {
    final data = await ApiClient.post(
      '/auth/register',
      data: {'nom': nom, 'email': email, 'motDePasse': motDePasse},
    );
    return _parseAuthResponse(data);
  }

  static AuthSession _parseAuthResponse(dynamic data) {
    if (data is! JsonMap) {
      throw const FormatException('Reponse auth invalide');
    }

    final token = (data['token'] as String?)?.trim() ?? '';
    final email = (data['email'] as String?)?.trim() ?? '';
    final nom = (data['nom'] as String?)?.trim() ?? '';
    final role = (data['role'] as String?)?.trim() ?? '';

    if (token.isEmpty || email.isEmpty || role.isEmpty) {
      throw const FormatException('Reponse auth incomplete');
    }

    return AuthSession(token: token, email: email, nom: nom, role: role);
  }
}
