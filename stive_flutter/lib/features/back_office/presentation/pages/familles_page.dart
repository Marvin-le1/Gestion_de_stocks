import 'package:flutter/material.dart';

import '../../../../core/utils/types.dart';
import '../../../../core/utils/validators.dart';
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
  static const int _pageSize = 20;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _future = FamillesService.findAll();
  }

  void _refresh() {
    setState(() {
      _future = FamillesService.findAll();
      _page = 0;
    });
  }

  Future<void> _openForm({JsonMap? famille}) async {
    String type = (famille?['type'] as String?) ?? _types.first;
    final descriptionController = TextEditingController(
      text: famille?['description'] as String? ?? '',
    );
    final formKey = GlobalKey<FormState>();
    bool autoValidate = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                autovalidateMode: autoValidate
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
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
                      onChanged: (value) => setModalState(() {
                        type = value ?? type;
                      }),
                      decoration: const InputDecoration(labelText: 'Type'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      validator: (value) => Validators.optionalText(
                        value ?? '',
                        'Description',
                        255,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: () async {
                          setModalState(() => autoValidate = true);
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          try {
                            if (famille == null) {
                              await FamillesService.create(
                                type: type,
                                description: Validators.normalize(
                                  descriptionController.text,
                                ),
                              );
                            } else {
                              await FamillesService.update(
                                famille['id'] as int,
                                type: type,
                                description: Validators.normalize(
                                  descriptionController.text,
                                ),
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
              ),
            );
          },
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
        final items = [...(snapshot.data ?? <JsonMap>[])];
        items.sort((a, b) {
          final aId = (a['id'] as num?)?.toInt() ?? 0;
          final bId = (b['id'] as num?)?.toInt() ?? 0;
          return bId.compareTo(aId);
        });
        final totalPages =
            items.isEmpty ? 1 : ((items.length - 1) ~/ _pageSize) + 1;
        final effectivePage = _page.clamp(0, totalPages - 1);
        final pagedItems = items
            .skip(effectivePage * _pageSize)
            .take(_pageSize)
            .toList();
        final startItem = items.isEmpty ? 0 : (effectivePage * _pageSize) + 1;
        final endItem = (effectivePage * _pageSize) + pagedItems.length;
        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
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
                    for (final item in pagedItems)
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
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: buildPaginationFooter(
                currentPage: effectivePage,
                totalPages: totalPages,
                totalItems: items.length,
                startItem: startItem,
                endItem: endItem,
                onPrevious: effectivePage > 0
                    ? () => setState(() => _page = effectivePage - 1)
                    : null,
                onNext: effectivePage < totalPages - 1
                    ? () => setState(() => _page = effectivePage + 1)
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }
}
