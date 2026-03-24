import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_client.dart';
import '../models/auth_session.dart';

class AuthSessionStore extends ValueNotifier<AuthSession?> {
  AuthSessionStore._() : super(null);

  static const _kToken = 'auth.token';
  static const _kEmail = 'auth.email';
  static const _kNom = 'auth.nom';
  static const _kRole = 'auth.role';

  static final AuthSessionStore instance = AuthSessionStore._();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    final restored = AuthSession.fromStorage({
      'token': prefs.getString(_kToken),
      'email': prefs.getString(_kEmail),
      'nom': prefs.getString(_kNom),
      'role': prefs.getString(_kRole),
    });

    value = restored;
    ApiClient.setAuthToken(restored?.token);
    ApiClient.setOnUnauthorizedHandler(logout);
  }

  Future<void> save(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, session.token);
    await prefs.setString(_kEmail, session.email);
    await prefs.setString(_kNom, session.nom);
    await prefs.setString(_kRole, session.role);

    value = session;
    ApiClient.setAuthToken(session.token);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kEmail);
    await prefs.remove(_kNom);
    await prefs.remove(_kRole);

    value = null;
    ApiClient.setAuthToken(null);
  }
}
