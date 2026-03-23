import '../../../core/network/api_client.dart';
import '../../../core/utils/types.dart';

class CommandesFournisseursService {
  CommandesFournisseursService._();

  static Future<List<JsonMap>> findAll() async {
    final data =
        await ApiClient.get('/commandes-fournisseurs') as List<dynamic>;
    return data.cast<JsonMap>();
  }

  static Future<JsonMap> create(JsonMap payload) async {
    return await ApiClient.post('/commandes-fournisseurs', data: payload)
        as JsonMap;
  }

  static Future<JsonMap> update(int id, JsonMap payload) async {
    return await ApiClient.put('/commandes-fournisseurs/$id', data: payload)
        as JsonMap;
  }

  static Future<void> delete(int id) {
    return ApiClient.delete('/commandes-fournisseurs/$id');
  }

  static Future<JsonMap> changerStatut(int id, String statut) async {
    return await ApiClient.patch(
          '/commandes-fournisseurs/$id/statut',
          data: {'statut': statut},
        )
        as JsonMap;
  }
}
