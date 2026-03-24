import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/types.dart';
import '../../../../core/utils/validators.dart';
import '../../../shared/services/articles_service.dart';
import '../../../shared/services/inventaires_service.dart';
import 'crud_helpers.dart';

class InventairesPage extends StatefulWidget {
  const InventairesPage({super.key});

  @override
  State<InventairesPage> createState() => _InventairesPageState();
}

class _InventairesPageState extends State<InventairesPage> {
  late Future<List<JsonMap>> _future;
  late Future<List<JsonMap>> _articlesFuture;
  static const int _pageSize = 20;
  int _page = 0;

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  double _toDouble(dynamic value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  int _stockForArticle(JsonMap article) {
    return _toInt(article['quantiteStock'] ?? article['stockActuel'] ?? article['stock']);
  }

  String _articleLabel(JsonMap article) {
    final designation = (article['designation'] as String?)?.trim();
    if (designation != null && designation.isNotEmpty) {
      return designation;
    }
    final reference = (article['reference'] as String?)?.trim();
    if (reference != null && reference.isNotEmpty) {
      return reference;
    }
    return 'Article #${article['id'] ?? '-'}';
  }

  String _formatEcart(int ecart) {
    if (ecart > 0) return '+$ecart';
    return '$ecart';
  }

  @override
  void initState() {
    super.initState();
    _future = InventairesService.findAll();
    _articlesFuture = ArticlesService.findAll();
  }

  void _refresh() => setState(() {
        _future = InventairesService.findAll();
      _articlesFuture = ArticlesService.findAll();
      _page = 0;
      });

  Widget _buildOverviewSection({
    required List<JsonMap> articles,
    required List<JsonMap> inventaires,
  }) {
    final sortedArticles = [...articles]
      ..sort((a, b) => _articleLabel(a).compareTo(_articleLabel(b)));

    final totalArticles = sortedArticles.length;
    final totalStock = sortedArticles.fold<int>(
      0,
      (sum, article) => sum + _stockForArticle(article),
    );
    final estimatedStockValue = sortedArticles.fold<double>(
      0,
      (sum, article) =>
          sum + (_stockForArticle(article) * _toDouble(article['prixUnitaire'])),
    );
    final lowStockCount = sortedArticles.where((article) {
      final seuil = _toInt(article['seuilMinimum'], fallback: 0);
      return _stockForArticle(article) <= seuil;
    }).length;
    final inventairesNonRegularises = inventaires
        .where((i) => i['regularise'] != true)
        .length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vue d\'ensemble du stock',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('Articles: $totalArticles')),
                Chip(label: Text('Stock total: $totalStock')),
                Chip(
                  label: Text(
                    'Valeur estimee: ${Formatters.money(estimatedStockValue)}',
                  ),
                ),
                Chip(label: Text('Sous seuil: $lowStockCount')),
                Chip(label: Text('Inventaires a regulariser: $inventairesNonRegularises')),
              ],
            ),
            const SizedBox(height: 10),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text('Detail de tout le stock'),
              subtitle: const Text('Quantite actuelle de chaque article'),
              children: [
                if (sortedArticles.isEmpty)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
                    child: Text('Aucun article en stock'),
                  )
                else
                  for (final article in sortedArticles)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(_articleLabel(article)),
                      subtitle: Text(
                        'Reference: ${(article['reference'] as String?) ?? '-'} • Seuil: ${_toInt(article['seuilMinimum'])}',
                      ),
                      trailing: Text(
                        '${_stockForArticle(article)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createInventaire() async {
    final articles = await ArticlesService.findAll();
    if (!mounted) return;

    final commentaireController = TextEditingController();
    final quantities = <int, TextEditingController>{};
    final baseStocks = <int, int>{};
    for (final a in articles) {
      final id = a['id'] as int;
      final baseStock = _stockForArticle(a);
      baseStocks[id] = baseStock;
      quantities[id] = TextEditingController(text: '$baseStock');
    }
    final formKey = GlobalKey<FormState>();
    bool autoValidate = false;

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
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Form(
                  key: formKey,
                  autovalidateMode: autoValidate
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nouvel inventaire',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: commentaireController,
                        decoration: const InputDecoration(
                          labelText: 'Commentaire',
                        ),
                        validator: (value) =>
                            Validators.commentaire(value ?? ''),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: articles.length,
                          itemBuilder: (context, index) {
                            final article = articles[index];
                            final id = article['id'] as int;
                            final controller = quantities[id]!;
                            final quantiteConstatee =
                                int.tryParse(Validators.normalize(controller.text)) ??
                                baseStocks[id]!;
                            final ecart = quantiteConstatee - baseStocks[id]!;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _articleLabel(article),
                                        style: Theme.of(context).textTheme.titleSmall,
                                      ),
                                      const SizedBox(height: 2),
                                      Text('Stock actuel: ${baseStocks[id]}'),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: controller,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: 'Quantite constatee',
                                        ),
                                        validator: (value) =>
                                            Validators.minIntRequired(
                                              value ?? '',
                                              'Quantite constatee',
                                              0,
                                            ),
                                        onChanged: (_) => setModalState(() {}),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Ecart: ${_formatEcart(ecart)}',
                                        style: TextStyle(
                                          color: ecart == 0
                                              ? null
                                              : ecart > 0
                                              ? Colors.green.shade700
                                              : Colors.red.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
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
                              final lignes = <JsonMap>[];
                              for (final entry in quantities.entries) {
                                final value = Validators.normalize(
                                  entry.value.text,
                                );
                                final qty = int.tryParse(value);
                                if (qty == null) {
                                  continue;
                                }
                                lignes.add({
                                  'articleId': entry.key,
                                  'quantiteConstatee': qty,
                                });
                              }
                              await InventairesService.create(
                                commentaire: Validators.normalize(
                                  commentaireController.text,
                                ),
                                lignes: lignes,
                              );
                              if (!mounted) return;
                              Navigator.pop(context);
                              _refresh();
                            } catch (e) {
                              if (!mounted) return;
                              showAppMessage(context, e.toString(), error: true);
                            }
                          },
                          child: const Text('Creer inventaire'),
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

  Widget _buildInventaireLignes(JsonMap inventaire) {
    final lignesRaw = inventaire['lignes'];
    if (lignesRaw is! List || lignesRaw.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Text('Aucune ligne pour cet inventaire'),
      );
    }

    final lignes = lignesRaw.cast<JsonMap>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Column(
        children: [
          for (final ligne in lignes)
            ListTile(
              dense: true,
              title: Text(
                _articleLabel((ligne['article'] as JsonMap?) ?? const {}),
              ),
              subtitle: Text(
                'Avant: ${_toInt(ligne['quantiteAvantRegularisation'])} • Constatee: ${_toInt(ligne['quantiteConstatee'])} • Ecart: ${_formatEcart(_toInt(ligne['ecart']))}',
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _regulariserInventaire(int inventaireId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Regulariser le stock'),
          content: const Text(
            'Cette action va mettre a jour le stock reel avec les quantites constatees. Continuer ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Regulariser'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await InventairesService.regulariser(inventaireId);
      if (!mounted) return;
      _refresh();
      showAppMessage(context, 'Stock regularise avec succes');
    } catch (e) {
      if (!mounted) return;
      showAppMessage(context, e.toString(), error: true);
    }
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

        return FutureBuilder<List<JsonMap>>(
          future: _articlesFuture,
          builder: (context, articlesSnapshot) {
            if (articlesSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (articlesSnapshot.hasError) {
              return Center(child: Text(articlesSnapshot.error.toString()));
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
            final startItem =
                items.isEmpty ? 0 : (effectivePage * _pageSize) + 1;
            final endItem = (effectivePage * _pageSize) + pagedItems.length;

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => _refresh(),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildOverviewSection(
                          articles: articlesSnapshot.data ?? const <JsonMap>[],
                          inventaires: items,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            onPressed: _createInventaire,
                            icon: const Icon(Icons.add),
                            label: const Text('Nouvel inventaire'),
                          ),
                        ),
                        for (final item in pagedItems)
                          Card(
                            child: ExpansionTile(
                              title: Text('Inventaire #${item['id']}'),
                              subtitle: Text(
                                'Date: ${Formatters.dateTime(item['dateInventaire'] as String?)}\nRegularise: ${item['regularise'] == true ? 'Oui' : 'Non'}',
                              ),
                              trailing: FilledButton.tonal(
                                onPressed: item['regularise'] == true
                                    ? null
                                    : () => _regulariserInventaire(
                                          item['id'] as int,
                                        ),
                                child: const Text('Regulariser'),
                              ),
                              children: [_buildInventaireLignes(item)],
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
      },
    );
  }
}
