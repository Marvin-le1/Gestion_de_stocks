import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/types.dart';
import '../../../../core/utils/validators.dart';
import '../../../shared/services/articles_service.dart';
import '../../../shared/services/familles_service.dart';
import '../../../shared/services/fournisseurs_service.dart';
import 'crud_helpers.dart';

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  late Future<List<JsonMap>> _future;

  @override
  void initState() {
    super.initState();
    _future = ArticlesService.findAll();
  }

  void _refresh() => setState(() {
        _future = ArticlesService.findAll();
      });

  Future<void> _openForm({JsonMap? article}) async {
    final familles = await FamillesService.findAll();
    final fournisseurs = await FournisseursService.findAll();

    if (!mounted) return;

    final fields = {
      'reference': TextEditingController(
        text: article?['reference'] as String? ?? '',
      ),
      'designation': TextEditingController(
        text: article?['designation'] as String? ?? '',
      ),
      'description': TextEditingController(
        text: article?['description'] as String? ?? '',
      ),
      'maison': TextEditingController(
        text: article?['maison'] as String? ?? '',
      ),
      'annee': TextEditingController(text: '${article?['annee'] ?? ''}'),
      'prixUnitaire': TextEditingController(
        text: '${article?['prixUnitaire'] ?? ''}',
      ),
      'prixCarton': TextEditingController(
        text: '${article?['prixCarton'] ?? ''}',
      ),
      'quantiteStock': TextEditingController(
        text: '${article?['quantiteStock'] ?? 0}',
      ),
      'seuilMinimum': TextEditingController(
        text: '${article?['seuilMinimum'] ?? 0}',
      ),
    };

    int? familleId = (article?['famille'] as JsonMap?)?['id'] as int?;
    int? fournisseurId = (article?['fournisseur'] as JsonMap?)?['id'] as int?;
    bool reapproAuto = (article?['reapprovisionnementAuto'] as bool?) ?? true;

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article == null ? 'Nouvel article' : 'Modifier article',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    for (final entry in fields.entries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TextField(
                          controller: entry.value,
                          keyboardType:
                              [
                                'annee',
                                'prixUnitaire',
                                'prixCarton',
                                'quantiteStock',
                                'seuilMinimum',
                              ].contains(entry.key)
                              ? TextInputType.number
                              : TextInputType.text,
                          decoration: InputDecoration(labelText: entry.key),
                        ),
                      ),
                    DropdownButtonFormField<int>(
                      value: familleId,
                      decoration: const InputDecoration(labelText: 'familleId'),
                      items: [
                        for (final f in familles)
                          DropdownMenuItem<int>(
                            value: f['id'] as int,
                            child: Text('${f['type']}'),
                          ),
                      ],
                      onChanged: (value) =>
                          setModalState(() => familleId = value),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: fournisseurId,
                      decoration: const InputDecoration(
                        labelText: 'fournisseurId',
                      ),
                      items: [
                        for (final f in fournisseurs)
                          DropdownMenuItem<int>(
                            value: f['id'] as int,
                            child: Text('${f['nom']}'),
                          ),
                      ],
                      onChanged: (value) =>
                          setModalState(() => fournisseurId = value),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: reapproAuto,
                      onChanged: (value) =>
                          setModalState(() => reapproAuto = value),
                      title: const Text('Reapprovisionnement auto'),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: () async {
                          try {
                            final validations = [
                              Validators.reference(fields['reference']!.text),
                              Validators.designation(
                                fields['designation']!.text,
                              ),
                              Validators.optionalText(
                                fields['description']!.text,
                                'Description',
                                500,
                              ),
                              Validators.optionalText(
                                fields['maison']!.text,
                                'Maison',
                                120,
                              ),
                              Validators.yearOptional(fields['annee']!.text),
                              Validators.positiveDecimalRequired(
                                fields['prixUnitaire']!.text,
                                'Prix unitaire',
                              ),
                              Validators.nonNegativeDecimalOptional(
                                fields['prixCarton']!.text,
                                'Prix carton',
                              ),
                              Validators.nonNegativeIntOptional(
                                fields['quantiteStock']!.text,
                                'Quantite stock',
                              ),
                              Validators.nonNegativeIntOptional(
                                fields['seuilMinimum']!.text,
                                'Seuil minimum',
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

                            if (familleId == null || fournisseurId == null) {
                              showAppMessage(
                                context,
                                'Champs obligatoires manquants',
                                error: true,
                              );
                              return;
                            }

                            final payload = {
                              'reference': Validators.normalize(
                                fields['reference']!.text,
                              ),
                              'designation': Validators.normalize(
                                fields['designation']!.text,
                              ),
                              'description': Validators.normalize(
                                fields['description']!.text,
                              ),
                              'maison': Validators.normalize(
                                fields['maison']!.text,
                              ),
                              'annee': int.tryParse(
                                Validators.normalize(fields['annee']!.text),
                              ),
                              'prixUnitaire':
                                  double.tryParse(
                                    Validators.normalize(
                                      fields['prixUnitaire']!.text,
                                    ).replaceAll(',', '.'),
                                  ) ??
                                  0,
                              'prixCarton':
                                  double.tryParse(
                                    Validators.normalize(
                                      fields['prixCarton']!.text,
                                    ).replaceAll(',', '.'),
                                  ) ??
                                  0,
                              'quantiteStock':
                                  int.tryParse(
                                    Validators.normalize(
                                      fields['quantiteStock']!.text,
                                    ),
                                  ) ??
                                  0,
                              'seuilMinimum':
                                  int.tryParse(
                                    Validators.normalize(
                                      fields['seuilMinimum']!.text,
                                    ),
                                  ) ??
                                  0,
                              'reapprovisionnementAuto': reapproAuto,
                              'familleId': familleId,
                              'fournisseurId': fournisseurId,
                            };

                            if (article == null) {
                              await ArticlesService.create(payload);
                            } else {
                              await ArticlesService.update(
                                article['id'] as int,
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
      },
    );
  }

  Future<void> _adjustStock(JsonMap article) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajuster le stock'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantite (+/-)'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  final message = Validators.nonNegativeIntOptional(
                    controller.text,
                    'Quantite',
                  );
                  if (message != null) {
                    showAppMessage(context, message, error: true);
                    return;
                  }
                  final quantite =
                      int.tryParse(Validators.normalize(controller.text)) ?? 0;
                  await ArticlesService.ajusterStock(
                    article['id'] as int,
                    quantite,
                  );
                  if (!mounted) return;
                  Navigator.pop(context);
                  _refresh();
                } catch (e) {
                  if (!mounted) return;
                  showAppMessage(context, e.toString(), error: true);
                }
              },
              child: const Text('Valider'),
            ),
          ],
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
              const SizedBox(height: 8),
              for (final item in items)
                Card(
                  child: ListTile(
                    title: Text(item['designation'] as String? ?? '-'),
                    subtitle: Text(
                      '${item['reference'] ?? '-'} • stock ${item['quantiteStock'] ?? 0} • ${Formatters.money(item['prixUnitaire'] as num?)}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          _openForm(article: item);
                        }
                        if (value == 'stock') {
                          _adjustStock(item);
                        }
                        if (value == 'toggle') {
                          try {
                            final actif =
                                (item['reapprovisionnementAuto'] as bool?) ??
                                false;
                            await ArticlesService.toggleReapprovisionnement(
                              item['id'] as int,
                              !actif,
                            );
                            _refresh();
                          } catch (e) {
                            if (!mounted) return;
                            showAppMessage(context, e.toString(), error: true);
                          }
                        }
                        if (value == 'delete') {
                          final yes = await confirmDelete(
                            context,
                            'cet article',
                          );
                          if (!yes) return;
                          try {
                            await ArticlesService.delete(item['id'] as int);
                            _refresh();
                          } catch (e) {
                            if (!mounted) return;
                            showAppMessage(context, e.toString(), error: true);
                          }
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Modifier')),
                        PopupMenuItem(
                          value: 'stock',
                          child: Text('Ajuster stock'),
                        ),
                        PopupMenuItem(
                          value: 'toggle',
                          child: Text('Toggle reappro auto'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Supprimer'),
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
