import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/types.dart';
import '../../../shared/models/cart_item.dart';
import '../../../shared/services/clients_service.dart';
import '../../../shared/services/commandes_clients_service.dart';

class ClientPanierPage extends StatefulWidget {
  const ClientPanierPage({
    required this.cart,
    required this.onCartChanged,
    required this.onClear,
    super.key,
  });

  final List<CartItem> cart;
  final VoidCallback onCartChanged;
  final VoidCallback onClear;

  @override
  State<ClientPanierPage> createState() => _ClientPanierPageState();
}

class _ClientPanierPageState extends State<ClientPanierPage> {
  late Future<List<JsonMap>> _clientsFuture;
  int? _selectedClientId;

  @override
  void initState() {
    super.initState();
    _clientsFuture = ClientsService.findAll();
  }

  Future<void> _checkout() async {
    if (_selectedClientId == null || widget.cart.isEmpty) return;

    try {
      await CommandesClientsService.create({
        'clientId': _selectedClientId,
        'commentaire': 'Commande via application mobile',
        'lignes': [
          for (final item in widget.cart)
            {'articleId': item.articleId, 'quantite': item.quantite},
        ],
      });

      if (!mounted) return;
      widget.onClear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commande envoyee avec succes')),
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
    final total = widget.cart.fold<double>(0, (acc, item) => acc + item.total);

    if (widget.cart.isEmpty) {
      return const Center(child: Text('Votre panier est vide'));
    }

    return FutureBuilder<List<JsonMap>>(
      future: _clientsFuture,
      builder: (context, snapshot) {
        final clients = snapshot.data ?? [];
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: DropdownButtonFormField<int>(
                value: _selectedClientId,
                decoration: const InputDecoration(
                  labelText: 'Client pour la commande',
                ),
                items: [
                  for (final c in clients)
                    DropdownMenuItem<int>(
                      value: c['id'] as int,
                      child: Text('${c['prenom'] ?? ''} ${c['nom'] ?? ''}'),
                    ),
                ],
                onChanged: (value) => setState(() => _selectedClientId = value),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.cart.length,
                itemBuilder: (context, index) {
                  final item = widget.cart[index];
                  return ListTile(
                    title: Text(item.designation),
                    subtitle: Text(Formatters.money(item.prixUnitaire)),
                    leading: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        if (item.quantite > 1) {
                          item.quantite -= 1;
                        } else {
                          widget.cart.removeAt(index);
                        }
                        widget.onCartChanged();
                      },
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('x${item.quantite}'),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            item.quantite += 1;
                            widget.onCartChanged();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Total: ${Formatters.money(total)}',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _selectedClientId == null ? null : _checkout,
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('Passer la commande'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: widget.onClear,
                    child: const Text('Vider le panier'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
