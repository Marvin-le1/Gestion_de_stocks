import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/types.dart';
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
      setState(() => _future = CommandesFournisseursService.findAll());

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
                      await CommandesFournisseursService.create({
                        'fournisseurId': fournisseurId,
                        'commentaire': commentaireController.text.trim(),
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
