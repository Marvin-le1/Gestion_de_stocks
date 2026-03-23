import 'package:flutter/material.dart';

class BackgroundShell extends StatelessWidget {
  const BackgroundShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F4EC), Color(0xFFF2E8D9), Color(0xFFF6EFE3)],
        ),
      ),
      child: child,
    );
  }
}
