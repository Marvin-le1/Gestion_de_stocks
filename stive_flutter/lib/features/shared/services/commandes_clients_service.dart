import '../../../core/network/api_client.dart';
import '../../../core/utils/types.dart';

class CommandesClientsService {
  CommandesClientsService._();

  static Future<List<JsonMap>> findAll() async {
    final data = await ApiClient.get('/commandes-clients') as List<dynamic>;
    return data.cast<JsonMap>();
  }

  static Future<JsonMap> create(JsonMap payload) async {
    return await ApiClient.post('/commandes-clients', data: payload) as JsonMap;
  }

  static Future<JsonMap> update(int id, JsonMap payload) async {
    return await ApiClient.put('/commandes-clients/$id', data: payload)
        as JsonMap;
  }

  static Future<void> delete(int id) =>
      ApiClient.delete('/commandes-clients/$id');

  static Future<JsonMap> changerStatut(int id, String statut) async {
    return await ApiClient.patch(
          '/commandes-clients/$id/statut',
          data: {'statut': statut},
        )
        as JsonMap;
  }

  static Future<List<JsonMap>> findLignes(int id) async {
    final data =
        await ApiClient.get('/commandes-clients/$id/lignes') as List<dynamic>;
    return data.cast<JsonMap>();
  }

  static Future<JsonMap> ajouterLigne(
    int id,
    int articleId,
    int quantite,
  ) async {
    return await ApiClient.post(
          '/commandes-clients/$id/lignes',
          data: {'articleId': articleId, 'quantite': quantite},
        )
        as JsonMap;
  }

  static Future<void> supprimerLigne(int id, int ligneId) {
    return ApiClient.delete('/commandes-clients/$id/lignes/$ligneId');
  }
}
