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
  static const int _pageSize = 20;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _future = InventairesService.findAll();
  }

  void _refresh() => setState(() {
        _future = InventairesService.findAll();
      _page = 0;
      });

  Future<void> _createInventaire() async {
    final articles = await ArticlesService.findAll();
    if (!mounted) return;

    final commentaireController = TextEditingController();
    final quantities = <int, TextEditingController>{
      for (final a in articles) a['id'] as int: TextEditingController(),
    };
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
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: TextFormField(
                                controller: quantities[id],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText:
                                      '${article['designation']} - quantite constatee',
                                ),
                                validator: (value) =>
                                    Validators.nonNegativeIntOptional(
                                      value ?? '',
                                      'Quantite constatee',
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
                                if (value.isEmpty) {
                                  continue;
                                }
                                final qty = int.tryParse(value);
                                if (qty != null) {
                                  lignes.add({
                                    'articleId': entry.key,
                                    'quantiteConstatee': qty,
                                  });
                                }
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
                        onPressed: _createInventaire,
                        icon: const Icon(Icons.add),
                        label: const Text('Nouvel inventaire'),
                      ),
                    ),
                    for (final item in pagedItems)
                      Card(
                        child: ListTile(
                          title: Text('Inventaire #${item['id']}'),
                          subtitle: Text(
                            'Date: ${Formatters.dateTime(item['dateInventaire'] as String?)}\nRegularise: ${item['regularise'] == true ? 'Oui' : 'Non'}',
                          ),
                          isThreeLine: true,
                          trailing: FilledButton.tonal(
                            onPressed: item['regularise'] == true
                                ? null
                                : () async {
                                    try {
                                      await InventairesService.regulariser(
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
                            child: const Text('Regulariser'),
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
