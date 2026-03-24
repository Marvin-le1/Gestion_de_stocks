import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/utils/types.dart';
import '../../../shared/services/fournisseurs_service.dart';
import 'crud_helpers.dart';

class FournisseursPage extends StatefulWidget {
  const FournisseursPage({super.key});

  @override
  State<FournisseursPage> createState() => _FournisseursPageState();
}

class _FournisseursPageState extends State<FournisseursPage> {
  late Future<List<JsonMap>> _future;
  static const int _pageSize = 20;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _future = FournisseursService.findAll();
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {
      _future = FournisseursService.findAll();
      _page = 0;
    });
  }

  Future<void> _openForm({JsonMap? fournisseur}) async {
    final fields = {
      'nom': TextEditingController(text: fournisseur?['nom'] as String? ?? ''),
      'adresse': TextEditingController(
        text: fournisseur?['adresse'] as String? ?? '',
      ),
      'ville': TextEditingController(
        text: fournisseur?['ville'] as String? ?? '',
      ),
      'codePostal': TextEditingController(
        text: fournisseur?['codePostal'] as String? ?? '',
      ),
      'telephone': TextEditingController(
        text: fournisseur?['telephone'] as String? ?? '',
      ),
      'email': TextEditingController(
        text: fournisseur?['email'] as String? ?? '',
      ),
      'contactNom': TextEditingController(
        text: fournisseur?['contactNom'] as String? ?? '',
      ),
    };
    String countryCode = Validators.inferCountryCode(
      phone: fields['telephone']!.text,
    );
    if (Validators.normalize(fields['telephone']!.text).isEmpty) {
      fields['telephone']!.text =
          Validators.countryByCode(countryCode).dialCode;
    } else {
      fields['telephone']!.text = Validators.applyDialCode(
        fields['telephone']!.text,
        countryCode,
      );
    }

    final formKey = GlobalKey<FormState>();
    bool autoValidate = false;

    String labelFor(String key) {
      switch (key) {
        case 'nom':
          return 'Nom';
        case 'adresse':
          return 'Adresse';
        case 'ville':
          return 'Ville';
        case 'codePostal':
          return 'Code postal';
        case 'telephone':
          return 'Telephone';
        case 'email':
          return 'Email';
        case 'contactNom':
          return 'Nom du contact';
        default:
          return key;
      }
    }

    String? hintFor(String key) {
      switch (key) {
        case 'nom':
          return 'Ex: Domaines du Sud';
        case 'adresse':
          return 'Ex: 8 avenue du Port';
        case 'ville':
          return 'Ex: Reims';
        case 'codePostal':
          return 'Ex: 51100';
        case 'telephone':
          return 'Ex: +33326123456';
        case 'email':
          return 'Ex: contact@domainesdusud.fr';
        case 'contactNom':
          return 'Ex: Paul Bernard';
        default:
          return null;
      }
    }

    String? validateField(String key, String value) {
      switch (key) {
        case 'nom':
          return Validators.strictText(value, 'Nom', required: true);
        case 'adresse':
          return Validators.address(value);
        case 'ville':
          return Validators.strictText(
            value,
            'Ville',
            maxLength: Validators.maxCityLength,
          );
        case 'codePostal':
          return Validators.postalCodeForCountry(value, countryCode);
        case 'telephone':
          return Validators.phoneForCountry(value, countryCode);
        case 'email':
          return Validators.email(value);
        case 'contactNom':
          return Validators.strictText(value, 'Contact');
        default:
          return null;
      }
    }

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
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  autovalidateMode: autoValidate
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fournisseur == null
                            ? 'Nouveau fournisseur'
                            : 'Modifier fournisseur',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: countryCode,
                        decoration: const InputDecoration(labelText: 'Pays'),
                        items: [
                          for (final country in Validators.countries)
                            DropdownMenuItem<String>(
                              value: country.code,
                              child: Text(
                                '${country.name} (${country.dialCode})',
                              ),
                            ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setModalState(() {
                            countryCode = value;
                            fields['telephone']!.text = Validators.applyDialCode(
                              fields['telephone']!.text,
                              countryCode,
                            );
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      for (final entry in fields.entries)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TextFormField(
                            controller: entry.value,
                            keyboardType: entry.key == 'email'
                                ? TextInputType.emailAddress
                                : entry.key == 'telephone' ||
                                      entry.key == 'codePostal'
                                ? TextInputType.phone
                                : TextInputType.text,
                            decoration: InputDecoration(
                              labelText: labelFor(entry.key),
                              hintText: hintFor(entry.key),
                            ),
                            validator: (value) =>
                                validateField(entry.key, value ?? ''),
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: () async {
                            setModalState(() => autoValidate = true);
                            if (!(formKey.currentState?.validate() ?? false)) {
                              return;
                            }
                            try {
                              final payload = {
                                'nom': Validators.normalize(fields['nom']!.text),
                                'adresse': Validators.normalize(
                                  fields['adresse']!.text,
                                ),
                                'ville': Validators.normalize(
                                  fields['ville']!.text,
                                ),
                                'codePostal': Validators.normalizePostalCode(
                                  fields['codePostal']!.text,
                                ),
                                'telephone': Validators.normalizePhoneForCountry(
                                  fields['telephone']!.text,
                                  countryCode,
                                ),
                                'email': Validators.normalize(
                                  fields['email']!.text,
                                ),
                                'contactNom': Validators.normalize(
                                  fields['contactNom']!.text,
                                ),
                              };
                              if (fournisseur == null) {
                                await FournisseursService.create(payload);
                              } else {
                                await FournisseursService.update(
                                  fournisseur['id'] as int,
                                  payload,
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
                    for (final item in pagedItems)
                      Card(
                        child: ListTile(
                          title: Text(item['nom'] as String? ?? '-'),
                          subtitle: Text(
                            '${item['ville'] ?? ''} • ${item['email'] ?? ''}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _openForm(fournisseur: item),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                onPressed: () async {
                                  final yes = await confirmDelete(
                                    context,
                                    'ce fournisseur',
                                  );
                                  if (!yes) return;
                                  try {
                                    await FournisseursService.delete(
                                      item['id'] as int,
                                    );
                                    if (!mounted) return;
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
