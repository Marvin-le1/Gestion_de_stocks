import 'package:dio/dio.dart';

import '../config/app_env.dart';
import '../utils/types.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient._();

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 25),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static String get apiPrefix => '${AppEnv.apiBaseUrl}/api';

  static Future<dynamic> get(String path) async {
    try {
      final response = await _dio.get('$apiPrefix$path');
      return response.data;
    } on DioException catch (e) {
      throw ApiException(_messageFromDio(e));
    }
  }

  static Future<dynamic> post(String path, {JsonMap? data}) async {
    try {
      final response = await _dio.post('$apiPrefix$path', data: data);
      return response.data;
    } on DioException catch (e) {
      throw ApiException(_messageFromDio(e));
    }
  }

  static Future<dynamic> put(String path, {JsonMap? data}) async {
    try {
      final response = await _dio.put('$apiPrefix$path', data: data);
      return response.data;
    } on DioException catch (e) {
      throw ApiException(_messageFromDio(e));
    }
  }

  static Future<dynamic> patch(String path, {JsonMap? data}) async {
    try {
      final response = await _dio.patch('$apiPrefix$path', data: data);
      return response.data;
    } on DioException catch (e) {
      throw ApiException(_messageFromDio(e));
    }
  }

  static Future<void> delete(String path) async {
    try {
      await _dio.delete('$apiPrefix$path');
    } on DioException catch (e) {
      throw ApiException(_messageFromDio(e));
    }
  }

  static String _messageFromDio(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      if (data['message'] is String) {
        return 'Erreur API ($status): ${data['message']}';
      }
      if (data['error'] is String) {
        return 'Erreur API ($status): ${data['error']}';
      }
    }
    return 'Erreur API ${status ?? ''}: ${e.message ?? 'Requete echouee'}';
  }
}
