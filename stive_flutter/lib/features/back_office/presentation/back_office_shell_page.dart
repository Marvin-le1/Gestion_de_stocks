import 'package:flutter/material.dart';

import 'pages/articles_page.dart';
import 'pages/clients_page.dart';
import 'pages/commandes_clients_page.dart';
import 'pages/commandes_fournisseurs_page.dart';
import 'pages/familles_page.dart';
import 'pages/fournisseurs_page.dart';
import 'pages/inventaires_page.dart';

class BackOfficeShellPage extends StatefulWidget {
  const BackOfficeShellPage({super.key});

  @override
  State<BackOfficeShellPage> createState() => _BackOfficeShellPageState();
}

class _BackOfficeShellPageState extends State<BackOfficeShellPage> {
  int _index = 0;

  final _items = const [
    _NavItem('Articles', Icons.inventory_2_outlined),
    _NavItem('Familles', Icons.local_bar_outlined),
    _NavItem('Fournisseurs', Icons.store_outlined),
    _NavItem('Clients', Icons.people_alt_outlined),
    _NavItem('Cmd clients', Icons.receipt_long_outlined),
    _NavItem('Cmd fourn.', Icons.local_shipping_outlined),
    _NavItem('Inventaires', Icons.fact_check_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      const ArticlesPage(),
      const FamillesPage(),
      const FournisseursPage(),
      const ClientsPage(),
      const CommandesClientsPage(),
      const CommandesFournisseursPage(),
      const InventairesPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Back-office • ${_items[_index].label}'),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              const ListTile(
                title: Text('NEGOSUD'),
                subtitle: Text('Gestion entrepot'),
              ),
              const Divider(),
              for (var i = 0; i < _items.length; i++)
                ListTile(
                  leading: Icon(_items[i].icon),
                  title: Text(_items[i].label),
                  selected: i == _index,
                  onTap: () {
                    setState(() => _index = i);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
      ),
      body: pages[_index],
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon);

  final String label;
  final IconData icon;
}
