import 'package:flutter/material.dart';

import '../../../../core/utils/types.dart';
import '../../../shared/services/familles_service.dart';
import 'crud_helpers.dart';

class FamillesPage extends StatefulWidget {
  const FamillesPage({super.key});

  @override
  State<FamillesPage> createState() => _FamillesPageState();
}

class _FamillesPageState extends State<FamillesPage> {
  late Future<List<JsonMap>> _future;
  final _types = const ['ROUGE', 'ROSE', 'BLANC', 'PETILLANT', 'DIGESTIF'];

  @override
  void initState() {
    super.initState();
    _future = FamillesService.findAll();
  }

  void _refresh() {
    setState(() => _future = FamillesService.findAll());
  }

  Future<void> _openForm({JsonMap? famille}) async {
    String type = (famille?['type'] as String?) ?? _types.first;
    final descriptionController = TextEditingController(
      text: famille?['description'] as String? ?? '',
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                famille == null ? 'Nouvelle famille' : 'Modifier famille',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: type,
                items: [
                  for (final item in _types)
                    DropdownMenuItem(value: item, child: Text(item)),
                ],
                onChanged: (value) => type = value ?? type,
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () async {
                    try {
                      if (famille == null) {
                        await FamillesService.create(
                          type: type,
                          description: descriptionController.text.trim(),
                        );
                      } else {
                        await FamillesService.update(
                          famille['id'] as int,
                          type: type,
                          description: descriptionController.text.trim(),
                        );
                      }
                      if (!mounted) return;
                      Navigator.pop(context);
                      _refresh();
                    } catch (e) {
                      if (!mounted) return;
                      showAppMessage(context, e.toString(), error: true);
                    }
                  },
                  child: const Text('Enregistrer'),
                ),
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
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        final items = snapshot.data ?? [];
        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => _openForm(),
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter'),
                ),
              ),
              const SizedBox(height: 8),
              for (final item in items)
                Card(
                  child: ListTile(
                    title: Text((item['type'] as String?) ?? '-'),
                    subtitle: Text((item['description'] as String?) ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _openForm(famille: item),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          onPressed: () async {
                            final yes = await confirmDelete(
                              context,
                              'cette famille',
                            );
                            if (!yes) return;
                            try {
                              await FamillesService.delete(item['id'] as int);
                              _refresh();
                            } catch (e) {
                              if (!mounted) return;
                              showAppMessage(
                                context,
                                e.toString(),
                                error: true,
                              );
                            }
                          },
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
