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

  @override
  void initState() {
    super.initState();
    _future = CommandesFournisseursService.findAll();
  }

  void _refresh() =>
      setState(() {
        _future = CommandesFournisseursService.findAll();
      });

  Future<void> _createCommande() async {
    final fournisseurs = await FournisseursService.findAll();
    if (!mounted) return;

    int? fournisseurId;
    final commentaireController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Nouvelle commande fournisseur'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: fournisseurId,
                    decoration: const InputDecoration(labelText: 'Fournisseur'),
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
                  TextField(
                    controller: commentaireController,
                    decoration: const InputDecoration(labelText: 'Commentaire'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: () async {
                    try {
                      if (fournisseurId == null) {
                        showAppMessage(
                          context,
                          'Selectionnez un fournisseur',
                          error: true,
                        );
                        return;
                      }

                      final commentError = Validators.commentaire(
                        commentaireController.text,
                      );
                      if (commentError != null) {
                        showAppMessage(context, commentError, error: true);
                        return;
                      }

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
                  child: const Text('Creer'),
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
                            onChanged: (value) =>
                                setModalState(() => articleId = value),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 110,
                          child: TextField(
                            controller: quantiteController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Quantite',
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
                          try {
                            final quantiteError = Validators.minIntRequired(
                              quantiteController.text,
                              'Quantite',
                              1,
                            );
                            if (articleId == null || quantiteError != null) {
                              showAppMessage(
                                context,
                                quantiteError ??
                                    'Selectionnez un article et une quantite valide',
                                error: true,
                              );
                              return;
                            }

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

        final items = snapshot.data ?? [];

        return RefreshIndicator(
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
              for (final item in items)
                Card(
                  child: ListTile(
                    title: Text('Commande #${item['id']} • ${item['statut']}'),
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
                            showAppMessage(context, e.toString(), error: true);
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
        );
      },
    );
  }
}
