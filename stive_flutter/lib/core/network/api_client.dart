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
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    ),
  );

  static String get apiPrefix => '${AppEnv.apiBaseUrl}/api';

  static String _resolveUrl(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$apiPrefix$normalizedPath';
  }

  static Future<dynamic> get(String path) async {
    try {
      final response = await _dio.get(_resolveUrl(path));
      return response.data;
    } on DioException catch (e) {
      throw ApiException(_messageFromDio(e));
    }
  }

  static Future<dynamic> post(String path, {JsonMap? data}) async {
    try {
      final payload = _normalizeData(data);
      final response = await _dio.post(_resolveUrl(path), data: payload);
      return response.data;
    } on DioException catch (e) {
      throw ApiException(_messageFromDio(e));
    }
  }

  static Future<dynamic> put(String path, {JsonMap? data}) async {
    try {
      final payload = _normalizeData(data);
      final response = await _dio.put(_resolveUrl(path), data: payload);
      return response.data;
    } on DioException catch (e) {
      throw ApiException(_messageFromDio(e));
    }
  }

  static Future<dynamic> patch(String path, {JsonMap? data}) async {
    try {
      final payload = _normalizeData(data);
      final response = await _dio.patch(_resolveUrl(path), data: payload);
      return response.data;
    } on DioException catch (e) {
      throw ApiException(_messageFromDio(e));
    }
  }

  static Future<void> delete(String path) async {
    try {
      await _dio.delete(_resolveUrl(path));
    } on DioException catch (e) {
      throw ApiException(_messageFromDio(e));
    }
  }

  static JsonMap? _normalizeData(JsonMap? data) {
    if (data == null) return null;

    final normalized = <String, dynamic>{};

    for (final entry in data.entries) {
      final value = entry.value;

      if (value is String) {
        final trimmed = value.trim();
        if (trimmed.isNotEmpty) {
          normalized[entry.key] = trimmed;
        }
        continue;
      }

      if (value == null) {
        continue;
      }

      normalized[entry.key] = value;
    }

    return normalized;
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

      final erreurs = data['erreurs'];
      if (erreurs is Map) {
        final details = erreurs.entries
            .map((entry) => '${entry.key}: ${entry.value}')
            .join(', ');
        if (details.isNotEmpty) {
          return 'Erreur API ($status): $details';
        }
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      return 'Erreur API ($status): ${data.trim()}';
    }

    return 'Erreur API ${status ?? ''}: ${e.message ?? 'Requete echouee'}';
  }
}
