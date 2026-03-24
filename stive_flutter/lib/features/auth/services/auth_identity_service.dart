import '../../../core/utils/types.dart';
import '../../shared/services/clients_service.dart';

class AuthIdentityService {
  AuthIdentityService._();

  static Future<JsonMap?> findClientByEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    final clients = await ClientsService.findAll();

    for (final client in clients) {
      final candidate = (client['email'] as String?)?.trim().toLowerCase();
      if (candidate == normalized) {
        return client;
      }
    }
    return null;
  }
}
