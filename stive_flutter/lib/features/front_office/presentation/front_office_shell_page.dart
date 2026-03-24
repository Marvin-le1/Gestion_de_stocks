import 'package:flutter/material.dart';

import '../../auth/models/auth_session.dart';
import '../../auth/services/auth_identity_service.dart';
import '../../../../core/utils/types.dart';
import '../../shared/models/cart_item.dart';
import 'pages/client_catalogue_page.dart';
import 'pages/client_orders_page.dart';
import 'pages/client_panier_page.dart';

class FrontOfficeShellPage extends StatefulWidget {
  const FrontOfficeShellPage({
    this.session,
    this.onLogout,
    this.onOpenProfile,
    this.onOpenManagerLogin,
    super.key,
  });

  final AuthSession? session;
  final Future<void> Function()? onLogout;
  final VoidCallback? onOpenProfile;
  final Future<void> Function()? onOpenManagerLogin;

  @override
  State<FrontOfficeShellPage> createState() => _FrontOfficeShellPageState();
}

class _FrontOfficeShellPageState extends State<FrontOfficeShellPage> {
  int _index = 0;
  final List<CartItem> _cart = [];
  Future<JsonMap>? _clientFuture;

  @override
  void initState() {
    super.initState();
    if (_isClient) {
      _clientFuture = _resolveClient();
    }
  }

  bool get _isClient => widget.session?.isClient ?? false;

  Future<JsonMap> _resolveClient() async {
    final userEmail = widget.session?.email ?? '';
    final client = await AuthIdentityService.findClientByEmail(userEmail);
    if (client == null) {
      throw StateError(
        'Aucun client associe a $userEmail. Verifiez la correspondance email.',
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

  Future<void> _openManagerLogin() async {
    await widget.onOpenManagerLogin?.call();
  }

  // ── visiteur non connecté ─────────────────────────────────────────────

  Widget _buildGuestScaffold() {
    final pages = [
      ClientCataloguePage(cart: _cart, onAddToCart: _addToCart),
      // clientId null → mode invité
      ClientPanierPage(
        cart: _cart,
        onCartChanged: () => setState(() {}),
        onClear: _clearCart,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Boutique'),
        actions: [
          FilledButton.tonalIcon(
            onPressed: _openManagerLogin,
            icon: const Icon(Icons.admin_panel_settings_outlined),
            label: const Text('Espace gérant'),
          ),
          const SizedBox(width: 12),
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
        ],
      ),
    );
  }

  // ── client connecté ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!_isClient) return _buildGuestScaffold();

    return FutureBuilder<JsonMap>(
      future: _clientFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Boutique')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () async => widget.onLogout?.call(),
                      child: const Text('Se déconnecter'),
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
          ClientCataloguePage(cart: _cart, onAddToCart: _addToCart),
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
            title: Text(
              'Boutique • ${client['prenom'] ?? ''} ${client['nom'] ?? ''}',
            ),
            actions: [
              IconButton(
                tooltip: 'Mon profil',
                icon: const Icon(Icons.account_circle_outlined),
                onPressed: widget.onOpenProfile,
              ),
              IconButton(
                tooltip: 'Se déconnecter',
                icon: const Icon(Icons.logout),
                onPressed: () async => widget.onLogout?.call(),
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
