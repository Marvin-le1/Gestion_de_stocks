import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/types.dart';
import '../../../shared/services/clients_service.dart';
import '../../../shared/services/commandes_clients_service.dart';
import 'crud_helpers.dart';

class CommandesClientsPage extends StatefulWidget {
  const CommandesClientsPage({super.key});

  @override
  State<CommandesClientsPage> createState() => _CommandesClientsPageState();
}

class _CommandesClientsPageState extends State<CommandesClientsPage> {
  late Future<List<JsonMap>> _future;

  @override
  void initState() {
    super.initState();
    _future = CommandesClientsService.findAll();
  }

  void _refresh() =>
      setState(() => _future = CommandesClientsService.findAll());

  Future<void> _createCommande() async {
    final clients = await ClientsService.findAll();
    if (!mounted) return;

    int? clientId;
    final commentaireController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Nouvelle commande client'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: clientId,
                      decoration: const InputDecoration(labelText: 'Client'),
                      items: [
                        for (final c in clients)
                          DropdownMenuItem<int>(
                            value: c['id'] as int,
                            child: Text(
                              '${c['prenom'] ?? ''} ${c['nom'] ?? ''}',
                            ),
                          ),
                      ],
                      onChanged: (value) =>
                          setModalState(() => clientId = value),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentaireController,
                      decoration: const InputDecoration(
                        labelText: 'Commentaire',
                      ),
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
                    try {
                      if (clientId == null) {
                        showAppMessage(
                          context,
                          'Selectionnez un client',
                          error: true,
                        );
                        return;
                      }
                      await CommandesClientsService.create({
                        'clientId': clientId,
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
                      await CommandesClientsService.changerStatut(
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
                      'Date: ${Formatters.dateTime(item['dateCommande'] as String?)}\nClient: ${(item['client'] as JsonMap?)?['nom'] ?? '-'}',
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
                            await CommandesClientsService.delete(
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
