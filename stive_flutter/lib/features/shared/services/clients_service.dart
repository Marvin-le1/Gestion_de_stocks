import '../../../core/network/api_client.dart';
import '../../../core/utils/types.dart';

class ClientsService {
  ClientsService._();

  static Future<List<JsonMap>> findAll() async {
    final data = await ApiClient.get('/clients') as List<dynamic>;
    return data.cast<JsonMap>();
  }

  static Future<JsonMap> create(JsonMap payload) async {
    return await ApiClient.post('/clients', data: payload) as JsonMap;
  }

  static Future<JsonMap> update(int id, JsonMap payload) async {
    return await ApiClient.put('/clients/$id', data: payload) as JsonMap;
  }

  static Future<void> delete(int id) => ApiClient.delete('/clients/$id');

  static Future<List<JsonMap>> findCommandes(int id) async {
    final data = await ApiClient.get('/clients/$id/commandes') as List<dynamic>;
    return data.cast<JsonMap>();
  }
}
