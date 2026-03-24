import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/utils/types.dart';
import '../../../shared/services/clients_service.dart';
import '../../models/auth_session.dart';
import '../../services/auth_identity_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    required this.session,
    required this.onSessionUpdated,
    super.key,
  });

  final AuthSession session;
  final Future<void> Function({String? nom, String? email}) onSessionUpdated;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _adresseController = TextEditingController();
  final _villeController = TextEditingController();
  final _codePostalController = TextEditingController();
  final _paysController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _autoValidate = false;
  int? _clientId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    _villeController.dispose();
    _codePostalController.dispose();
    _paysController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      _nomController.text = widget.session.nom;
      _emailController.text = widget.session.email;

      if (widget.session.isClient) {
        final client = await AuthIdentityService.findClientByEmail(
          widget.session.email,
        );
        if (client != null) {
          _hydrateClient(client);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _hydrateClient(JsonMap client) {
    _clientId = client['id'] as int?;
    _nomController.text = (client['nom'] as String?) ?? _nomController.text;
    _prenomController.text = (client['prenom'] as String?) ?? '';
    _emailController.text = (client['email'] as String?) ?? _emailController.text;
    _telephoneController.text = (client['telephone'] as String?) ?? '';
    _adresseController.text = (client['adresse'] as String?) ?? '';
    _villeController.text = (client['ville'] as String?) ?? '';
    _codePostalController.text = (client['codePostal'] as String?) ?? '';
    _paysController.text = (client['pays'] as String?) ?? '';
  }

  Future<void> _save() async {
    if (_saving) return;

    setState(() => _autoValidate = true);
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    try {
      setState(() => _saving = true);

      if (widget.session.isClient && _clientId != null) {
        await ClientsService.update(_clientId!, {
          'nom': Validators.normalize(_nomController.text),
          'prenom': Validators.normalize(_prenomController.text),
          'email': Validators.normalize(_emailController.text),
          'telephone': Validators.normalize(_telephoneController.text),
          'adresse': Validators.normalize(_adresseController.text),
          'ville': Validators.normalize(_villeController.text),
          'codePostal': Validators.normalize(_codePostalController.text),
          'pays': Validators.normalize(_paysController.text),
        });
      }

      await widget.onSessionUpdated(
        nom: Validators.normalize(_nomController.text),
        email: Validators.normalize(_emailController.text),
      );

      if (!mounted) return;
      final partial = widget.session.isClient && _clientId == null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            partial
                ? 'Profil local mis a jour. Liaison client API non trouvee.'
                : 'Profil mis a jour',
          ),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autoValidate
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Role: ${widget.session.role}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nomController,
                        decoration: const InputDecoration(
                          labelText: 'Nom',
                          hintText: 'Ex: Martin',
                        ),
                        validator: (value) => Validators.requiredText(
                          value ?? '',
                          'Nom',
                          maxLength: Validators.maxNameLength,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _prenomController,
                        decoration: const InputDecoration(
                          labelText: 'Prenom',
                          hintText: 'Ex: Camille',
                        ),
                        validator: (value) {
                          if (!widget.session.isClient) return null;
                          return Validators.requiredText(
                            value ?? '',
                            'Prenom',
                            maxLength: Validators.maxNameLength,
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'Ex: camille.martin@mail.com',
                        ),
                        validator: (value) =>
                            Validators.email(value ?? '', required: true),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _telephoneController,
                        decoration: const InputDecoration(
                          labelText: 'Telephone',
                          hintText: 'Ex: +33612345678',
                        ),
                        validator: (value) =>
                            Validators.phoneInternational(value ?? ''),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _adresseController,
                        decoration: const InputDecoration(
                          labelText: 'Adresse',
                          hintText: 'Ex: 12 rue des Vignes',
                        ),
                        validator: (value) {
                          final text = Validators.normalize(value ?? '');
                          if (text.isEmpty) return null;
                          return Validators.hasMaxLength(
                                text,
                                Validators.maxAddressLength,
                              )
                              ? null
                              : 'Adresse trop longue';
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _villeController,
                        decoration: const InputDecoration(
                          labelText: 'Ville',
                          hintText: 'Ex: Bordeaux',
                        ),
                        validator: (value) {
                          final text = Validators.normalize(value ?? '');
                          if (text.isEmpty) return null;
                          return Validators.hasMaxLength(
                                text,
                                Validators.maxCityLength,
                              )
                              ? null
                              : 'Ville trop longue';
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _codePostalController,
                        decoration: const InputDecoration(
                          labelText: 'Code postal',
                          hintText: 'Ex: 33000',
                        ),
                        validator: (value) {
                          final text = Validators.normalize(value ?? '');
                          if (text.isEmpty) return null;
                          return Validators.hasMaxLength(
                                text,
                                Validators.maxPostalCodeLength,
                              )
                              ? null
                              : 'Code postal trop long';
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _paysController,
                        decoration: const InputDecoration(
                          labelText: 'Pays',
                          hintText: 'Ex: France',
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (widget.session.isClient && _clientId == null)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Profil client API introuvable pour cet email. La sauvegarde mettra seulement a jour la session locale.',
                          ),
                        ),
                      if (widget.session.isClient && _clientId == null)
                        const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: const Icon(Icons.save_outlined),
                        label: Text(_saving ? 'Sauvegarde...' : 'Enregistrer'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
