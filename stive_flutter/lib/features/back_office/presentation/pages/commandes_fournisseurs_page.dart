import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/types.dart';
import '../../../../core/utils/validators.dart';
import '../../../shared/services/articles_service.dart';
import '../../../shared/services/commandes_fournisseurs_service.dart';
import '../../../shared/services/fournisseurs_service.dart';
import 'crud_helpers.dart';

class CommandesFournisseursPage extends StatefulWidget {
  const CommandesFournisseursPage({super.key});

  @override
  State<CommandesFournisseursPage> createState() =>
      _CommandesFournisseursPageState();
}

class _CommandesFournisseursPageState extends State<CommandesFournisseursPage> {
  late Future<List<JsonMap>> _future;
  static const int _pageSize = 20;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _future = CommandesFournisseursService.findAll();
  }

  void _refresh() =>
      setState(() {
        _future = CommandesFournisseursService.findAll();
        _page = 0;
      });

  Future<void> _createCommande() async {
    final fournisseurs = await FournisseursService.findAll();
    if (!mounted) return;

    int? fournisseurId;
    final commentaireController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool autoValidate = false;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Nouvelle commande fournisseur'),
              content: Form(
                key: formKey,
                autovalidateMode: autoValidate
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                          value == null ? 'Sélectionnez un fournisseur' : null,
                      onChanged: (value) =>
                          setModalState(() => fournisseurId = value),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: commentaireController,
                      decoration: const InputDecoration(labelText: 'Commentaire'),
                      validator: (value) => Validators.commentaire(value ?? ''),
                    ),
                  ],
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
                      await CommandesFournisseursService.create({
                        'fournisseurId': fournisseurId,
                        'commentaire': Validators.normalize(
                          commentaireController.text,
                        ),
                        'lignes': <JsonMap>[],
                      });
                      if (!mounted) return;
                      Navigator.pop(context);
                      _refresh();
                    } catch (e) {
                      if (!mounted) return;
                      showAppMessage(context, e.toString(), error: true);
                    }
                  },
                  child: const Text('Créer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _changeStatus(JsonMap commande) async {
    const statuts = ['EN_ATTENTE', 'VALIDEE', 'LIVREE', 'ANNULEE'];
    String statut = (commande['statut'] as String?) ?? statuts.first;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Changer statut'),
              content: DropdownButtonFormField<String>(
                value: statut,
                items: [
                  for (final s in statuts)
                    DropdownMenuItem(value: s, child: Text(s)),
                ],
                onChanged: (value) =>
                    setModalState(() => statut = value ?? statut),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: () async {
                    try {
                      await CommandesFournisseursService.changerStatut(
                        commande['id'] as int,
                        statut,
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

  Future<void> _manageLignes(int commandeId) async {
    final articles = await ArticlesService.findAll();
    if (!mounted) return;

    int? articleId;
    final quantiteController = TextEditingController(text: '1');
    final formKey = GlobalKey<FormState>();
    bool autoValidate = false;
    Future<List<JsonMap>> lignesFuture =
        CommandesFournisseursService.findLignes(commandeId);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text('Lignes commande #$commandeId'),
              content: SizedBox(
                width: 600,
                height: 420,
                child: Form(
                  key: formKey,
                  autovalidateMode: autoValidate
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: articleId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Article',
                            ),
                            items: [
                              for (final article in articles)
                                DropdownMenuItem<int>(
                                  value: article['id'] as int,
                                  child: Text(
                                    article['designation'] as String? ??
                                        'Article',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                            validator: (value) =>
                                value == null ? 'Sélectionnez un article' : null,
                            onChanged: (value) =>
                                setModalState(() => articleId = value),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 110,
                          child: TextFormField(
                            controller: quantiteController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Quantite',
                            ),
                            validator: (value) => Validators.minIntRequired(
                              value ?? '',
                              'Quantite',
                              1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: () async {
                          setModalState(() => autoValidate = true);
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          try {
                            final quantite = int.parse(
                              Validators.normalize(quantiteController.text),
                            );

                            await CommandesFournisseursService.ajouterLigne(
                              commandeId,
                              articleId!,
                              quantite,
                            );

                            setModalState(() {
                              lignesFuture =
                                  CommandesFournisseursService.findLignes(
                                    commandeId,
                                  );
                              quantiteController.text = '1';
                            });
                          } catch (e) {
                            if (!mounted) return;
                            showAppMessage(context, e.toString(), error: true);
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter ligne'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: FutureBuilder<List<JsonMap>>(
                        future: lignesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(snapshot.error.toString()),
                            );
                          }

                          final lignes = snapshot.data ?? [];
                          if (lignes.isEmpty) {
                            return const Center(
                              child: Text('Aucune ligne pour cette commande'),
                            );
                          }

                          return ListView.separated(
                            itemCount: lignes.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final ligne = lignes[index];
                              final article =
                                  (ligne['article'] as JsonMap?) ?? const {};
                              final designation =
                                  article['designation'] as String? ??
                                  'Article #${ligne['articleId'] ?? '-'}';
                              final quantite = ligne['quantite'] ?? '-';
                              final ligneId = ligne['id'];

                              return ListTile(
                                title: Text(designation),
                                subtitle: Text('Quantite: $quantite'),
                                trailing: IconButton(
                                  tooltip: 'Supprimer la ligne',
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: ligneId is! int
                                      ? null
                                      : () async {
                                          try {
                                            await CommandesFournisseursService.supprimerLigne(
                                              commandeId,
                                              ligneId,
                                            );
                                            setModalState(() {
                                              lignesFuture =
                                                  CommandesFournisseursService.findLignes(
                                                    commandeId,
                                                  );
                                            });
                                          } catch (e) {
                                            if (!mounted) return;
                                            showAppMessage(
                                              context,
                                              e.toString(),
                                              error: true,
                                            );
                                          }
                                        },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fermer'),
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
                        onPressed: _createCommande,
                        icon: const Icon(Icons.add),
                        label: const Text('Nouvelle commande'),
                      ),
                    ),
                    for (final item in pagedItems)
                      Card(
                        child: ListTile(
                          title: Text(
                            'Commande #${item['id']} • ${item['statut']}',
                          ),
                          subtitle: Text(
                            'Date: ${Formatters.dateTime(item['dateCommande'] as String?)}\nFournisseur: ${(item['fournisseur'] as JsonMap?)?['nom'] ?? '-'}',
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'status') {
                                _changeStatus(item);
                              }
                              if (value == 'lignes') {
                                _manageLignes(item['id'] as int);
                              }
                              if (value == 'delete') {
                                final yes = await confirmDelete(
                                  context,
                                  'cette commande',
                                );
                                if (!yes) return;
                                try {
                                  await CommandesFournisseursService.delete(
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
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'lignes',
                                child: Text('Gerer les lignes'),
                              ),
                              PopupMenuItem(
                                value: 'status',
                                child: Text('Changer statut'),
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
