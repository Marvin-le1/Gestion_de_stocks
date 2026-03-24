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
  static const int _pageSize = 20;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _future = ClientsService.findAll();
  }

  void _refresh() => setState(() {
        _future = ClientsService.findAll();
      _page = 0;
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
    final formKey = GlobalKey<FormState>();
    bool autoValidate = false;

    String labelFor(String key) {
      switch (key) {
        case 'nom':
          return 'Nom';
        case 'prenom':
          return 'Prenom';
        case 'email':
          return 'Email';
        case 'telephone':
          return 'Telephone';
        case 'adresse':
          return 'Adresse';
        case 'ville':
          return 'Ville';
        case 'codePostal':
          return 'Code postal';
        default:
          return key;
      }
    }

    String? validateField(String key, String value) {
      switch (key) {
        case 'nom':
          return Validators.strictText(value, 'Nom', required: true);
        case 'prenom':
          return Validators.strictText(value, 'Prenom', required: true);
        case 'email':
          return Validators.email(value, required: true);
        case 'telephone':
          return Validators.phoneInternational(value);
        case 'adresse':
          return Validators.address(value);
        case 'ville':
          return Validators.strictText(
            value,
            'Ville',
            maxLength: Validators.maxCityLength,
          );
        case 'codePostal':
          return Validators.postalCodeInternational(value);
        default:
          return null;
      }
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  autovalidateMode: autoValidate
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
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
                          child: TextFormField(
                            controller: entry.value,
                            keyboardType: entry.key == 'email'
                                ? TextInputType.emailAddress
                                : entry.key == 'telephone' ||
                                      entry.key == 'codePostal'
                                ? TextInputType.phone
                                : TextInputType.text,
                            decoration: InputDecoration(
                              labelText: labelFor(entry.key),
                            ),
                            validator: (value) =>
                                validateField(entry.key, value ?? ''),
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: () async {
                            setModalState(() => autoValidate = true);
                            if (!(formKey.currentState?.validate() ?? false)) {
                              return;
                            }
                            try {
                              final payload = {
                                'nom': Validators.normalize(fields['nom']!.text),
                                'prenom': Validators.normalize(
                                  fields['prenom']!.text,
                                ),
                                'email': Validators.normalize(
                                  fields['email']!.text,
                                ),
                                'telephone': Validators.normalize(
                                  fields['telephone']!.text,
                                ),
                                'adresse': Validators.normalize(
                                  fields['adresse']!.text,
                                ),
                                'ville': Validators.normalize(
                                  fields['ville']!.text,
                                ),
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
              ),
            );
          },
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
        final items = [...(snapshot.data ?? <JsonMap>[])];
        items.sort((a, b) {
          final aId = (a['id'] as num?)?.toInt() ?? 0;
          final bId = (b['id'] as num?)?.toInt() ?? 0;
          return bId.compareTo(aId);
        });
        final totalPages =
            items.isEmpty ? 1 : ((items.length - 1) ~/ _pageSize) + 1;
        final effectivePage = _page.clamp(0, totalPages - 1);
        final pagedItems = items
            .skip(effectivePage * _pageSize)
            .take(_pageSize)
            .toList();
        final startItem = items.isEmpty ? 0 : (effectivePage * _pageSize) + 1;
        final endItem = (effectivePage * _pageSize) + pagedItems.length;
        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
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
                    for (final item in pagedItems)
                      Card(
                        child: ListTile(
                          title: Text(
                            '${item['prenom'] ?? ''} ${item['nom'] ?? ''}',
                          ),
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
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: buildPaginationFooter(
                currentPage: effectivePage,
                totalPages: totalPages,
                totalItems: items.length,
                startItem: startItem,
                endItem: endItem,
                onPrevious: effectivePage > 0
                    ? () => setState(() => _page = effectivePage - 1)
                    : null,
                onNext: effectivePage < totalPages - 1
                    ? () => setState(() => _page = effectivePage + 1)
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }
}
