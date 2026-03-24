import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/utils/types.dart';
import '../../../shared/services/clients_service.dart';
import 'crud_helpers.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  late Future<List<JsonMap>> _future;

  @override
  void initState() {
    super.initState();
    _future = ClientsService.findAll();
  }

  void _refresh() => setState(() {
        _future = ClientsService.findAll();
      });

  Future<void> _openForm({JsonMap? client}) async {
    final fields = {
      'nom': TextEditingController(text: client?['nom'] as String? ?? ''),
      'prenom': TextEditingController(text: client?['prenom'] as String? ?? ''),
      'email': TextEditingController(text: client?['email'] as String? ?? ''),
      'telephone': TextEditingController(
        text: client?['telephone'] as String? ?? '',
      ),
      'adresse': TextEditingController(
        text: client?['adresse'] as String? ?? '',
      ),
      'ville': TextEditingController(text: client?['ville'] as String? ?? ''),
      'codePostal': TextEditingController(
        text: client?['codePostal'] as String? ?? '',
      ),
    };

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client == null ? 'Nouveau client' : 'Modifier client',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                for (final entry in fields.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: entry.value,
                      decoration: InputDecoration(labelText: entry.key),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () async {
                      try {
                        final validations = [
                          Validators.strictText(
                            fields['nom']!.text,
                            'Nom',
                            required: true,
                          ),
                          Validators.strictText(
                            fields['prenom']!.text,
                            'Prenom',
                            required: true,
                          ),
                          Validators.email(
                            fields['email']!.text,
                            required: true,
                          ),
                          Validators.phoneInternational(
                            fields['telephone']!.text,
                          ),
                          Validators.address(fields['adresse']!.text),
                          Validators.strictText(
                            fields['ville']!.text,
                            'Ville',
                            maxLength: Validators.maxCityLength,
                          ),
                          Validators.postalCodeInternational(
                            fields['codePostal']!.text,
                          ),
                        ];

                        final firstError = validations.firstWhere(
                          (v) => v != null,
                          orElse: () => null,
                        );
                        if (firstError != null) {
                          showAppMessage(context, firstError, error: true);
                          return;
                        }

                        final payload = {
                          'nom': Validators.normalize(fields['nom']!.text),
                          'prenom': Validators.normalize(
                            fields['prenom']!.text,
                          ),
                          'email': Validators.normalize(fields['email']!.text),
                          'telephone': Validators.normalize(
                            fields['telephone']!.text,
                          ),
                          'adresse': Validators.normalize(
                            fields['adresse']!.text,
                          ),
                          'ville': Validators.normalize(fields['ville']!.text),
                          'codePostal': Validators.normalize(
                            fields['codePostal']!.text,
                          ),
                        };
                        if (client == null) {
                          await ClientsService.create(payload);
                        } else {
                          await ClientsService.update(
                            client['id'] as int,
                            payload,
                          );
                        }
                        if (!mounted) return;
                        Navigator.pop(context);
                        _refresh();
                      } catch (e) {
                        if (!mounted) return;
                        showAppMessage(context, e.toString(), error: true);
                      }
                    },
                    child: const Text('Enregistrer'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<JsonMap>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        final items = snapshot.data ?? [];
        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => _openForm(),
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter'),
                ),
              ),
              for (final item in items)
                Card(
                  child: ListTile(
                    title: Text('${item['prenom'] ?? ''} ${item['nom'] ?? ''}'),
                    subtitle: Text(item['email'] as String? ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _openForm(client: item),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          onPressed: () async {
                            final yes = await confirmDelete(
                              context,
                              'ce client',
                            );
                            if (!yes) return;
                            try {
                              await ClientsService.delete(item['id'] as int);
                              _refresh();
                            } catch (e) {
                              if (!mounted) return;
                              showAppMessage(
                                context,
                                e.toString(),
                                error: true,
                              );
                            }
                          },
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
