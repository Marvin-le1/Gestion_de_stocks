import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/models/auth_session.dart';
import '../features/auth/presentation/pages/auth_page.dart';
import '../features/auth/presentation/pages/profile_page.dart';
import '../features/auth/services/auth_session_store.dart';
import '../features/back_office/presentation/back_office_shell_page.dart';
import '../features/front_office/presentation/front_office_shell_page.dart';

class NegosudApp extends StatefulWidget {
  const NegosudApp({super.key});

  @override
  State<NegosudApp> createState() => _NegosudAppState();
}

class _NegosudAppState extends State<NegosudApp> {
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = AuthSessionStore.instance.initialize();
  }

  Future<void> _openProfile(BuildContext context, AuthSession session) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfilePage(
          session: session,
          onSessionUpdated: ({String? nom, String? email}) async {
            final current = AuthSessionStore.instance.value;
            if (current == null) return;
            final updated = AuthSession(
              token: current.token,
              email: (email == null || email.trim().isEmpty)
                  ? current.email
                  : email.trim(),
              nom: (nom == null || nom.trim().isEmpty) ? current.nom : nom.trim(),
              role: current.role,
            );
            await AuthSessionStore.instance.save(updated);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NEGOSUD',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return ValueListenableBuilder<AuthSession?>(
            valueListenable: AuthSessionStore.instance,
            builder: (context, session, _) {
              if (session == null) {
                return const AuthPage();
              }

              if (session.isAdmin) {
                return BackOfficeShellPage(
                  onLogout: AuthSessionStore.instance.logout,
                  onOpenProfile: () => _openProfile(context, session),
                );
              }

              if (session.isClient) {
                return FrontOfficeShellPage(
                  userEmail: session.email,
                  onLogout: AuthSessionStore.instance.logout,
                  onOpenProfile: () => _openProfile(context, session),
                );
              }

              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 44),
                        const SizedBox(height: 8),
                        Text('Role non supporte: ${session.role}'),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: AuthSessionStore.instance.logout,
                          child: const Text('Se deconnecter'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
