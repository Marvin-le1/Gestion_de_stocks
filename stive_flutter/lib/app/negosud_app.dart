import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/startup/presentation/role_selector_page.dart';

class NegosudApp extends StatelessWidget {
  const NegosudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NEGOSUD',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const RoleSelectorPage(),
    );
  }
}
