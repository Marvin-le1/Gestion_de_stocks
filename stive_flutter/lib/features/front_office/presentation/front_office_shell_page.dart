import 'package:flutter/material.dart';

import '../../shared/models/cart_item.dart';
import 'pages/client_catalogue_page.dart';
import 'pages/client_orders_page.dart';
import 'pages/client_panier_page.dart';

class FrontOfficeShellPage extends StatefulWidget {
  const FrontOfficeShellPage({super.key});

  @override
  State<FrontOfficeShellPage> createState() => _FrontOfficeShellPageState();
}

class _FrontOfficeShellPageState extends State<FrontOfficeShellPage> {
  int _index = 0;
  final List<CartItem> _cart = [];

  void _addToCart(CartItem item) {
    final existing = _cart
        .where((e) => e.articleId == item.articleId)
        .firstOrNull;
    setState(() {
      if (existing != null) {
        existing.quantite += item.quantite;
      } else {
        _cart.add(item);
      }
    });
  }

  void _clearCart() => setState(_cart.clear);

  @override
  Widget build(BuildContext context) {
    final pages = [
      ClientCataloguePage(onAddToCart: _addToCart),
      ClientPanierPage(
        cart: _cart,
        onCartChanged: () => setState(() {}),
        onClear: _clearCart,
      ),
      const ClientOrdersPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Front-office client'),
        actions: [
          IconButton(
            tooltip: 'Changer d\'espace',
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.wine_bar_outlined),
            label: 'Catalogue',
          ),
          NavigationDestination(
            icon: const Icon(Icons.shopping_cart_outlined),
            label: _cart.isEmpty ? 'Panier' : 'Panier (${_cart.length})',
          ),
          const NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            label: 'Commandes',
          ),
        ],
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    if (isEmpty) return null;
    return first;
  }
}
