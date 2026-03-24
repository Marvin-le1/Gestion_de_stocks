import 'package:flutter/material.dart';

import '../../auth/services/auth_identity_service.dart';
import '../../../../core/utils/types.dart';
import '../../shared/models/cart_item.dart';
import 'pages/client_catalogue_page.dart';
import 'pages/client_orders_page.dart';
import 'pages/client_panier_page.dart';

class FrontOfficeShellPage extends StatefulWidget {
  const FrontOfficeShellPage({
    required this.userEmail,
    required this.onLogout,
    required this.onOpenProfile,
    super.key,
  });

  final String userEmail;
  final Future<void> Function() onLogout;
  final VoidCallback onOpenProfile;

  @override
  State<FrontOfficeShellPage> createState() => _FrontOfficeShellPageState();
}

class _FrontOfficeShellPageState extends State<FrontOfficeShellPage> {
  int _index = 0;
  final List<CartItem> _cart = [];
  late Future<JsonMap> _clientFuture;

  @override
  void initState() {
    super.initState();
    _clientFuture = _resolveClient();
  }

  Future<JsonMap> _resolveClient() async {
    final client = await AuthIdentityService.findClientByEmail(widget.userEmail);
    if (client == null) {
      throw StateError(
        'Aucun client associe a ${widget.userEmail}. Verifiez la correspondance email.',
      );
    }
    return client;
  }

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
    return FutureBuilder<JsonMap>(
      future: _clientFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Boutique')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(snapshot.error.toString(), textAlign: TextAlign.center),
                    const SizedBox(height: 10),
                    FilledButton(
                      onPressed: () async => widget.onLogout(),
                      child: const Text('Se deconnecter'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final client = snapshot.data!;
        final clientId = client['id'] as int;
        final pages = [
          ClientCataloguePage(onAddToCart: _addToCart),
          ClientPanierPage(
            clientId: clientId,
            cart: _cart,
            onCartChanged: () => setState(() {}),
            onClear: _clearCart,
          ),
          ClientOrdersPage(clientId: clientId),
        ];

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text('Boutique • ${client['prenom'] ?? ''} ${client['nom'] ?? ''}'),
            actions: [
              IconButton(
                tooltip: 'Mon profil',
                icon: const Icon(Icons.account_circle_outlined),
                onPressed: widget.onOpenProfile,
              ),
              IconButton(
                tooltip: 'Se deconnecter',
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await widget.onLogout();
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
      },
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    if (isEmpty) return null;
    return first;
  }
}
