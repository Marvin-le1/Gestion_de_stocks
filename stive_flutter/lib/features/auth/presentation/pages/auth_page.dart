import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/background_shell.dart';
import '../../services/auth_service.dart';
import '../../services/auth_session_store.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isRegister = false;
  bool _submitting = false;
  bool _autoValidate = false;

  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _motDePasseController = TextEditingController();

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;

    setState(() => _autoValidate = true);
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    try {
      setState(() => _submitting = true);

      final session = _isRegister
          ? await AuthService.register(
              nom: Validators.normalize(_nomController.text),
              email: Validators.normalize(_emailController.text),
              motDePasse: _motDePasseController.text,
            )
          : await AuthService.login(
              email: Validators.normalize(_emailController.text),
              motDePasse: _motDePasseController.text,
            );

      await AuthSessionStore.instance.save(session);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isRegister
                ? 'Compte cree et connexion reussie'
                : 'Connexion reussie',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundShell(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _autoValidate
                          ? AutovalidateMode.always
                          : AutovalidateMode.disabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'NEGOSUD',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isRegister ? 'Creer un compte' : 'Se connecter',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 20),
                          if (_isRegister) ...[
                            TextFormField(
                              controller: _nomController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Nom',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (value) => Validators.requiredText(
                                value ?? '',
                                'Nom',
                                maxLength: Validators.maxNameLength,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.alternate_email),
                            ),
                            validator: (value) =>
                                Validators.email(value ?? '', required: true),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _motDePasseController,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              labelText: 'Mot de passe',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            validator: (value) {
                              final raw = value ?? '';
                              if (raw.trim().isEmpty) {
                                return 'Mot de passe requis';
                              }
                              if (_isRegister && raw.length < 6) {
                                return 'Minimum 6 caracteres';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: _submitting ? null : _submit,
                            icon: Icon(
                              _isRegister
                                  ? Icons.app_registration
                                  : Icons.login,
                            ),
                            label: Text(
                              _submitting
                                  ? 'Traitement...'
                                  : (_isRegister
                                        ? 'Creer un compte'
                                        : 'Connexion'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _submitting
                                ? null
                                : () {
                                    setState(() {
                                      _isRegister = !_isRegister;
                                      _autoValidate = false;
                                    });
                                  },
                            child: Text(
                              _isRegister
                                  ? 'Deja un compte ? Se connecter'
                                  : 'Pas de compte ? Creer un compte',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
