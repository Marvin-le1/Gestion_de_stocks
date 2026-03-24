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
  static const int _pageSize = 20;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _future = ArticlesService.findAll();
  }

  void _refresh() => setState(() {
        _future = ArticlesService.findAll();
      _page = 0;
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
    final formKey = GlobalKey<FormState>();
    bool autoValidate = false;

    String labelFor(String key) {
      switch (key) {
        case 'reference':
          return 'Reference';
        case 'designation':
          return 'Designation';
        case 'description':
          return 'Description';
        case 'maison':
          return 'Maison';
        case 'annee':
          return 'Annee';
        case 'prixUnitaire':
          return 'Prix unitaire';
        case 'prixCarton':
          return 'Prix carton';
        case 'quantiteStock':
          return 'Quantite en stock';
        case 'seuilMinimum':
          return 'Seuil minimum';
        default:
          return key;
      }
    }

    String? validateField(String key, String value) {
      switch (key) {
        case 'reference':
          return Validators.reference(value);
        case 'designation':
          return Validators.designation(value);
        case 'description':
          return Validators.optionalText(value, 'Description', 500);
        case 'maison':
          return Validators.optionalText(value, 'Maison', 120);
        case 'annee':
          return Validators.yearOptional(value);
        case 'prixUnitaire':
          return Validators.positiveDecimalRequired(value, 'Prix unitaire');
        case 'prixCarton':
          return Validators.nonNegativeDecimalOptional(value, 'Prix carton');
        case 'quantiteStock':
          return Validators.nonNegativeIntOptional(value, 'Quantite stock');
        case 'seuilMinimum':
          return Validators.nonNegativeIntOptional(value, 'Seuil minimum');
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
                        article == null ? 'Nouvel article' : 'Modifier article',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      for (final entry in fields.entries)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TextFormField(
                            controller: entry.value,
                            keyboardType:
                                [
                                  'annee',
                                  'prixUnitaire',
                                  'prixCarton',
                                  'quantiteStock',
                                  'seuilMinimum',
                                ].contains(entry.key)
                                ? const TextInputType.numberWithOptions(
                                    decimal: true,
                                  )
                                : TextInputType.text,
                            decoration: InputDecoration(
                              labelText: labelFor(entry.key),
                            ),
                            validator: (value) =>
                                validateField(entry.key, value ?? ''),
                          ),
                        ),
                      DropdownButtonFormField<int>(
                        value: familleId,
                        decoration: const InputDecoration(
                          labelText: 'Famille',
                        ),
                        items: [
                          for (final f in familles)
                            DropdownMenuItem<int>(
                              value: f['id'] as int,
                              child: Text('${f['type']}'),
                            ),
                        ],
                        validator: (value) =>
                            value == null ? 'Famille est requise' : null,
                        onChanged: (value) =>
                            setModalState(() => familleId = value),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: fournisseurId,
                        decoration: const InputDecoration(
                          labelText: 'Fournisseur',
                        ),
                        items: [
                          for (final f in fournisseurs)
                            DropdownMenuItem<int>(
                              value: f['id'] as int,
                              child: Text('${f['nom']}'),
                            ),
                        ],
                        validator: (value) =>
                            value == null ? 'Fournisseur est requis' : null,
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
                            setModalState(() => autoValidate = true);
                            if (!(formKey.currentState?.validate() ?? false)) {
                              return;
                            }

                            try {
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
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _adjustStock(JsonMap article) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool autoValidate = false;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Ajuster le stock'),
              content: Form(
                key: formKey,
                autovalidateMode: autoValidate
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantite (+/-)',
                  ),
                  validator: (value) =>
                      Validators.nonNegativeIntOptional(value ?? '', 'Quantite'),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: () async {
                    setModalState(() => autoValidate = true);
                    if (!(formKey.currentState?.validate() ?? false)) {
                      return;
                    }
                    try {
                      final quantite =
                          int.tryParse(Validators.normalize(controller.text)) ??
                          0;
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
                    const SizedBox(height: 8),
                    for (final item in pagedItems)
                      Card(
                        child: ListTile(
                          title: Text(item['designation'] as String? ?? '-'),
                          subtitle: Text(
                            '${item['reference'] ?? '-'} • stock ${item['quantiteStock'] ?? 0} • ${Formatters.money(item['prixUnitaire'] as num?)}\nReappro: ${((item['reapprovisionnementAuto'] as bool?) ?? false) ? 'Actif' : 'Inactif'}',
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
