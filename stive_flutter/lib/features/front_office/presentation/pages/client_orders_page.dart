import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/types.dart';
import '../../../shared/services/clients_service.dart';
import '../../../shared/services/commandes_clients_service.dart';

class ClientOrdersPage extends StatefulWidget {
  const ClientOrdersPage({super.key});

  @override
  State<ClientOrdersPage> createState() => _ClientOrdersPageState();
}

class _ClientOrdersPageState extends State<ClientOrdersPage> {
  late Future<List<JsonMap>> _clientsFuture;
  int? _selectedClientId;
  Future<List<JsonMap>>? _ordersFuture;

  @override
  void initState() {
    super.initState();
    _clientsFuture = ClientsService.findAll();
  }

  Future<void> _loadOrders() async {
    if (_selectedClientId == null) return;
    setState(() {
      _ordersFuture = ClientsService.findCommandes(_selectedClientId!);
    });
  }

  Widget _buildOrderLines(int commandeId) {
    return FutureBuilder<List<JsonMap>>(
      future: CommandesClientsService.findLignes(commandeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Text(snapshot.error.toString()),
          );
        }

        final lignes = snapshot.data ?? [];
        if (lignes.isEmpty) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text('Aucune ligne pour cette commande'),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Column(
            children: [
              for (final ligne in lignes)
                ListTile(
                  dense: true,
                  title: Text(
                    ((ligne['article'] as JsonMap?)?['designation']
                            as String?) ??
                        'Article #${ligne['articleId'] ?? '-'}',
                  ),
                  subtitle: Text('Quantite: ${ligne['quantite'] ?? '-'}'),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<JsonMap>>(
      future: _clientsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        final clients = snapshot.data ?? [];

        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                value: _selectedClientId,
                decoration: const InputDecoration(
                  labelText: 'Selectionner votre client',
                ),
                items: [
                  for (final c in clients)
                    DropdownMenuItem<int>(
                      value: c['id'] as int,
                      child: Text('${c['prenom'] ?? ''} ${c['nom'] ?? ''}'),
                    ),
                ],
                onChanged: (value) {
                  setState(() => _selectedClientId = value);
                  _loadOrders();
                },
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _ordersFuture == null
                    ? const Center(child: Text('Choisissez un client'))
                    : FutureBuilder<List<JsonMap>>(
                        future: _ordersFuture,
                        builder: (context, ordersSnap) {
                          if (ordersSnap.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (ordersSnap.hasError) {
                            return Center(
                              child: Text(ordersSnap.error.toString()),
                            );
                          }

                          final orders = ordersSnap.data ?? [];
                          if (orders.isEmpty) {
                            return const Center(child: Text('Aucune commande'));
                          }

                          return ListView.builder(
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              final order = orders[index];
                              final commandeId = order['id'] as int;
                              return Card(
                                child: ExpansionTile(
                                  title: Text('Commande #${order['id']}'),
                                  subtitle: Text(
                                    '${order['statut']} • ${Formatters.dateTime(order['dateCommande'] as String?)}',
                                  ),
                                  trailing: IconButton(
                                    tooltip: 'Actualiser la liste',
                                    onPressed: _loadOrders,
                                    icon: const Icon(Icons.refresh),
                                  ),
                                  children: [_buildOrderLines(commandeId)],
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
