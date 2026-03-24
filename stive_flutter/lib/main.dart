import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/negosud_app.dart';
import 'core/config/app_env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await AppEnv.load();
  } catch (e, st) {
    debugPrint('AppEnv.load() failed: $e');
    debugPrint('$st');
    await dotenv.load(fileName: '.env');
  }

  runApp(const NegosudApp());
}
