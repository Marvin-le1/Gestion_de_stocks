import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/back_office/presentation/back_office_shell_page.dart';

class NegosudApp extends StatelessWidget {
  const NegosudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NEGOSUD',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const BackOfficeShellPage(),
    );
  }
}
