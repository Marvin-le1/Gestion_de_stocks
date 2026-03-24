import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/types.dart';
import '../../../shared/models/cart_item.dart';
import '../../../shared/services/articles_service.dart';

class ClientCataloguePage extends StatefulWidget {
  const ClientCataloguePage({required this.onAddToCart, super.key});

  final void Function(CartItem item) onAddToCart;

  @override
  State<ClientCataloguePage> createState() => _ClientCataloguePageState();
}

class _ClientCataloguePageState extends State<ClientCataloguePage> {
  late Future<List<JsonMap>> _future;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _future = ArticlesService.findAll();
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

        final all = snapshot.data ?? [];
        final items = all.where((item) {
          final text = ('${item['designation']} ${item['reference']}')
              .toLowerCase();
          return text.contains(_search.toLowerCase());
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Rechercher un produit',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => setState(() => _search = value),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      title: Text(item['designation'] as String? ?? '-'),
                      subtitle: Text(
                        '${item['maison'] ?? ''} • ${Formatters.money(item['prixUnitaire'] as num?)}',
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          widget.onAddToCart(
                            CartItem(article: item, quantite: 1),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Ajoute au panier')),
                          );
                        },
                        icon: const Icon(Icons.add_shopping_cart_outlined),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
