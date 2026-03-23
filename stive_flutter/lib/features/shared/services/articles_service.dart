import '../../../core/network/api_client.dart';
import '../../../core/utils/types.dart';

class ArticlesService {
  ArticlesService._();

  static Future<List<JsonMap>> findAll() async {
    final data = await ApiClient.get('/articles') as List<dynamic>;
    return data.cast<JsonMap>();
  }

  static Future<JsonMap> create(JsonMap payload) async {
    return await ApiClient.post('/articles', data: payload) as JsonMap;
  }

  static Future<JsonMap> update(int id, JsonMap payload) async {
    return await ApiClient.put('/articles/$id', data: payload) as JsonMap;
  }

  static Future<void> delete(int id) => ApiClient.delete('/articles/$id');

  static Future<JsonMap> ajusterStock(int id, int quantite) async {
    return await ApiClient.patch(
          '/articles/$id/stock',
          data: {'quantite': quantite},
        )
        as JsonMap;
  }

  static Future<JsonMap> toggleReapprovisionnement(int id, bool actif) async {
    return await ApiClient.patch(
          '/articles/$id/reapprovisionnement',
          data: {'actif': actif},
        )
        as JsonMap;
  }

  static Future<List<JsonMap>> findByFournisseur(int fournisseurId) async {
    final data =
        await ApiClient.get('/articles/fournisseur/$fournisseurId')
            as List<dynamic>;
    return data.cast<JsonMap>();
  }

  static Future<List<JsonMap>> findByFamille(int familleId) async {
    final data =
        await ApiClient.get('/articles/famille/$familleId') as List<dynamic>;
    return data.cast<JsonMap>();
  }
}
