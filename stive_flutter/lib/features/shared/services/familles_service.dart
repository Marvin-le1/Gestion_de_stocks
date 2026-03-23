import '../../../core/network/api_client.dart';
import '../../../core/utils/types.dart';

class FamillesService {
  FamillesService._();

  static Future<List<JsonMap>> findAll() async {
    final data = await ApiClient.get('/familles') as List<dynamic>;
    return data.cast<JsonMap>();
  }

  static Future<JsonMap> create({
    required String type,
    String? description,
  }) async {
    return await ApiClient.post(
          '/familles',
          data: {'type': type, 'description': description},
        )
        as JsonMap;
  }

  static Future<JsonMap> update(
    int id, {
    required String type,
    String? description,
  }) async {
    return await ApiClient.put(
          '/familles/$id',
          data: {'type': type, 'description': description},
        )
        as JsonMap;
  }

  static Future<void> delete(int id) => ApiClient.delete('/familles/$id');
}
