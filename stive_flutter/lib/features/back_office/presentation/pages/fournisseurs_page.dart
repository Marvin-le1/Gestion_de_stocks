import 'package:flutter/material.dart';

import '../../../../core/utils/types.dart';
import '../../../shared/services/fournisseurs_service.dart';
import 'crud_helpers.dart';

class FournisseursPage extends StatefulWidget {
  const FournisseursPage({super.key});

  @override
  State<FournisseursPage> createState() => _FournisseursPageState();
}

class _FournisseursPageState extends State<FournisseursPage> {
  late Future<List<JsonMap>> _future;

  @override
  void initState() {
    super.initState();
    _future = FournisseursService.findAll();
  }

  void _refresh() => setState(() => _future = FournisseursService.findAll());

  Future<void> _openForm({JsonMap? fournisseur}) async {
    final fields = {
      'nom': TextEditingController(text: fournisseur?['nom'] as String? ?? ''),
      'adresse': TextEditingController(
        text: fournisseur?['adresse'] as String? ?? '',
      ),
      'ville': TextEditingController(
        text: fournisseur?['ville'] as String? ?? '',
      ),
      'codePostal': TextEditingController(
        text: fournisseur?['codePostal'] as String? ?? '',
      ),
      'telephone': TextEditingController(
        text: fournisseur?['telephone'] as String? ?? '',
      ),
      'email': TextEditingController(
        text: fournisseur?['email'] as String? ?? '',
      ),
      'contactNom': TextEditingController(
        text: fournisseur?['contactNom'] as String? ?? '',
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
                  fournisseur == null
                      ? 'Nouveau fournisseur'
                      : 'Modifier fournisseur',
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
                        if (fields['nom']!.text.trim().isEmpty) {
                          showAppMessage(
                            context,
                            'Le nom est requis',
                            error: true,
                          );
                          return;
                        }
                        final payload = {
                          for (final e in fields.entries)
                            e.key: e.value.text.trim(),
                        };
                        if (fournisseur == null) {
                          await FournisseursService.create(payload);
                        } else {
                          await FournisseursService.update(
                            fournisseur['id'] as int,
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
                    title: Text(item['nom'] as String? ?? '-'),
                    subtitle: Text(
                      '${item['ville'] ?? ''} • ${item['email'] ?? ''}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _openForm(fournisseur: item),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          onPressed: () async {
                            final yes = await confirmDelete(
                              context,
                              'ce fournisseur',
                            );
                            if (!yes) return;
                            try {
                              await FournisseursService.delete(
                                item['id'] as int,
                              );
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
