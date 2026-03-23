import '../../../core/network/api_client.dart';
import '../../../core/utils/types.dart';

class InventairesService {
  InventairesService._();

  static Future<List<JsonMap>> findAll() async {
    final data = await ApiClient.get('/inventaires') as List<dynamic>;
    return data.cast<JsonMap>();
  }

  static Future<JsonMap> findById(int id) async {
    return await ApiClient.get('/inventaires/$id') as JsonMap;
  }

  static Future<JsonMap> create({
    String? commentaire,
    required List<JsonMap> lignes,
  }) async {
    return await ApiClient.post(
          '/inventaires',
          data: {'commentaire': commentaire, 'lignes': lignes},
        )
        as JsonMap;
  }

  static Future<JsonMap> regulariser(int id) async {
    return await ApiClient.post('/inventaires/$id/regulariser') as JsonMap;
  }
}
