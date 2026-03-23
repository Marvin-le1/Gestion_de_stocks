import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  AppEnv._();

  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  static String get apiBaseUrl {
    final value = dotenv.env['URL_NGROK']?.trim() ?? '';
    if (value.isEmpty) {
      return 'http://10.0.2.2:8080';
    }
    return value;
  }
}
