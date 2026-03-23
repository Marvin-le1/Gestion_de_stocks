import '../../../core/network/api_client.dart';
import '../../../core/utils/types.dart';

class FournisseursService {
  FournisseursService._();

  static Future<List<JsonMap>> findAll() async {
    final data = await ApiClient.get('/fournisseurs') as List<dynamic>;
    return data.cast<JsonMap>();
  }

  static Future<JsonMap> create(JsonMap payload) async {
    return await ApiClient.post('/fournisseurs', data: payload) as JsonMap;
  }

  static Future<JsonMap> update(int id, JsonMap payload) async {
    return await ApiClient.put('/fournisseurs/$id', data: payload) as JsonMap;
  }

  static Future<void> delete(int id) => ApiClient.delete('/fournisseurs/$id');

  static Future<List<JsonMap>> findArticles(int id) async {
    final data =
        await ApiClient.get('/fournisseurs/$id/articles') as List<dynamic>;
    return data.cast<JsonMap>();
  }
}
