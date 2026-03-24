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

  @override
  void initState() {
    super.initState();
    _future = InventairesService.findAll();
  }

  void _refresh() => setState(() {
        _future = InventairesService.findAll();
      });

  Future<void> _createInventaire() async {
    final articles = await ArticlesService.findAll();
    if (!mounted) return;

    final commentaireController = TextEditingController();
    final quantities = <int, TextEditingController>{
      for (final a in articles) a['id'] as int: TextEditingController(),
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
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nouvel inventaire',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: commentaireController,
                  decoration: const InputDecoration(labelText: 'Commentaire'),
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
                        child: TextField(
                          controller: quantities[id],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText:
                                '${article['designation']} - quantite constatee',
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
                      try {
                        final commentError = Validators.commentaire(
                          commentaireController.text,
                        );
                        if (commentError != null) {
                          showAppMessage(context, commentError, error: true);
                          return;
                        }

                        final lignes = <JsonMap>[];
                        for (final entry in quantities.entries) {
                          final value = Validators.normalize(entry.value.text);
                          if (value.isEmpty) {
                            continue;
                          }
                          final qtyError = Validators.nonNegativeIntOptional(
                            value,
                            'Quantite constatee',
                          );
                          if (qtyError != null) {
                            showAppMessage(context, qtyError, error: true);
                            return;
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
                  onPressed: _createInventaire,
                  icon: const Icon(Icons.add),
                  label: const Text('Nouvel inventaire'),
                ),
              ),
              for (final item in items)
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
        );
      },
    );
  }
}
