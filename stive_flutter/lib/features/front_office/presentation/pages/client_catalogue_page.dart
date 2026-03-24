import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/types.dart';
import '../../../shared/models/cart_item.dart';
import '../../../shared/services/articles_service.dart';

class ClientCataloguePage extends StatefulWidget {
  const ClientCataloguePage({
    required this.cart,
    required this.onAddToCart,
    super.key,
  });

  final List<CartItem> cart;
  final void Function(CartItem item) onAddToCart;

  @override
  State<ClientCataloguePage> createState() => _ClientCataloguePageState();
}

class _ClientCataloguePageState extends State<ClientCataloguePage> {
  late Future<List<JsonMap>> _future;
  String _search = '';

  int _quantityForArticle(int articleId) {
    return widget.cart
        .where((item) => item.articleId == articleId)
        .fold(0, (sum, item) => sum + item.quantite);
  }

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
                  hintText: 'Ex: Bordeaux, VIN-001, maison',
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
                  final rawId = item['id'];
                  final articleId = rawId is num ? rawId.toInt() : null;
                  final quantityInCart = articleId == null
                      ? 0
                      : _quantityForArticle(articleId);
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (quantityInCart > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '$quantityInCart',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          IconButton(
                            onPressed: () {
                              widget.onAddToCart(
                                CartItem(article: item, quantite: 1),
                              );
                              HapticFeedback.selectionClick();
                            },
                            icon: const Icon(Icons.add_shopping_cart_outlined),
                          ),
                        ],
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
