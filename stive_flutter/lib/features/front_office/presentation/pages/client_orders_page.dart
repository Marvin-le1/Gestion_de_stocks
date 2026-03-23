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

  Future<void> _createQuickOrder() async {
    if (_selectedClientId == null) return;
    try {
      await CommandesClientsService.create({
        'clientId': _selectedClientId,
        'commentaire': 'Commande front-office',
        'lignes': <JsonMap>[],
      });
      await _loadOrders();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commande creee (ajoutez des lignes en back-office)'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
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
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: _selectedClientId == null
                      ? null
                      : _createQuickOrder,
                  icon: const Icon(Icons.add),
                  label: const Text('Creer commande'),
                ),
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
                              return Card(
                                child: ListTile(
                                  title: Text('Commande #${order['id']}'),
                                  subtitle: Text(
                                    '${order['statut']} • ${Formatters.dateTime(order['dateCommande'] as String?)}',
                                  ),
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
