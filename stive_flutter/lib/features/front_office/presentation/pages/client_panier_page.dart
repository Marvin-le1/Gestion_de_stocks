import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../shared/models/cart_item.dart';
import '../../../shared/services/commandes_clients_service.dart';

class ClientPanierPage extends StatefulWidget {
  const ClientPanierPage({
    required this.clientId,
    required this.cart,
    required this.onCartChanged,
    required this.onClear,
    super.key,
  });

  final int clientId;
  final List<CartItem> cart;
  final VoidCallback onCartChanged;
  final VoidCallback onClear;

  @override
  State<ClientPanierPage> createState() => _ClientPanierPageState();
}

class _ClientPanierPageState extends State<ClientPanierPage> {
  final TextEditingController _commentaireController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _sending = false;

  @override
  void dispose() {
    _commentaireController.dispose();
    super.dispose();
  }

  int? _stockFor(CartItem item) {
    final article = item.article;
    final raw =
        article['quantiteStock'] ?? article['stockActuel'] ?? article['stock'];
    if (raw is num) return raw.toInt();
    return null;
  }

  Future<void> _checkout() async {
    if (widget.cart.isEmpty || _sending) return;

    final total = widget.cart.fold<double>(0, (acc, item) => acc + item.total);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmer la commande'),
          content: Text(
            'Client: #${widget.clientId}\nArticles: ${widget.cart.length}\nTotal: ${Formatters.money(total)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Valider'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      setState(() => _autoValidate = true);
      if (!(_formKey.currentState?.validate() ?? false)) {
        return;
      }

      final invalidLine = widget.cart.any((item) => item.quantite <= 0);
      if (invalidLine) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Le panier contient une quantité invalide')),
        );
        return;
      }

      setState(() => _sending = true);
      await CommandesClientsService.create({
        'clientId': widget.clientId,
        'commentaire': Validators.normalize(_commentaireController.text).isEmpty
            ? 'Commande via application mobile'
            : Validators.normalize(_commentaireController.text),
        'lignes': [
          for (final item in widget.cart)
            {'articleId': item.articleId, 'quantite': item.quantite},
        ],
      });

      if (!mounted) return;
      widget.onClear();
      _commentaireController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commande envoyée avec succès')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.cart.fold<double>(0, (acc, item) => acc + item.total);

    if (widget.cart.isEmpty) {
      return const Center(child: Text('Votre panier est vide'));
    }

    return Form(
      key: _formKey,
      autovalidateMode: _autoValidate
          ? AutovalidateMode.always
          : AutovalidateMode.disabled,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Commande pour le client #${widget.clientId}'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.cart.length,
              itemBuilder: (context, index) {
                final item = widget.cart[index];
                return ListTile(
                  title: Text(item.designation),
                  subtitle: Text(
                    '${Formatters.money(item.prixUnitaire)}${_stockFor(item) == null ? '' : ' • Stock: ${_stockFor(item)}'}',
                  ),
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
                          final stock = _stockFor(item);
                          if (stock != null && item.quantite >= stock) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Stock maximum atteint'),
                              ),
                            );
                            return;
                          }
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
                TextFormField(
                  controller: _commentaireController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Commentaire (optionnel)',
                    hintText: 'Ex: livraison en matinee',
                  ),
                  validator: (value) => Validators.commentaire(value ?? ''),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: ${Formatters.money(total)}',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _sending ? null : _checkout,
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: Text(
                    _sending ? 'Envoi en cours...' : 'Passer la commande',
                  ),
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
      ),
    );
  }
}
