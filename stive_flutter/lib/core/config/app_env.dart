import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  AppEnv._();

  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  static String get apiBaseUrl {
    final rawValue = dotenv.env['URL_NGROK']?.trim() ?? '';
    final fallback = 'http://10.0.2.2:8080';
    final base = rawValue.isEmpty ? fallback : rawValue;

    var sanitized = base;
    if (sanitized.endsWith('/')) {
      sanitized = sanitized.substring(0, sanitized.length - 1);
    }

    if (sanitized.toLowerCase().endsWith('/api')) {
      sanitized = sanitized.substring(0, sanitized.length - 4);
    }

    return sanitized;
  }
}
