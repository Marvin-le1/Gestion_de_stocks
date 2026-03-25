import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../shared/models/cart_item.dart';
import '../../../shared/services/clients_service.dart';
import '../../../shared/services/commandes_clients_service.dart';

/// Page panier — gère deux cas :
///   • [clientId] fourni  → client connecté (comportement historique)
///   • [clientId] null    → visiteur : saisie email → lookup → commande invitée
class ClientPanierPage extends StatefulWidget {
  const ClientPanierPage({
    this.clientId,
    required this.cart,
    required this.onCartChanged,
    required this.onClear,
    super.key,
  });

  final int? clientId;
  final List<CartItem> cart;
  final VoidCallback onCartChanged;
  final VoidCallback onClear;

  @override
  State<ClientPanierPage> createState() => _ClientPanierPageState();
}

enum _GuestStep { emailEntry, loading, notFound, returning }

class _ClientPanierPageState extends State<ClientPanierPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _sending = false;

  final TextEditingController _commentaireCtrl = TextEditingController();

  // ── mode invité ───────────────────────────────────────────────────────
  _GuestStep _guestStep = _GuestStep.emailEntry;
  bool _returningClientConfirmed = false;
  Map<String, dynamic>? _resolvedClient;

  final TextEditingController _emailCtrl = TextEditingController();

  late final AnimationController _stepAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _stepAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _stepAnim, curve: Curves.easeInOut);
    _stepAnim.forward();
  }

  @override
  void dispose() {
    _stepAnim.dispose();
    _commentaireCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  bool get _isConnected => widget.clientId != null;

  int? _stockFor(CartItem item) {
    final raw =
        item.article['quantiteStock'] ??
        item.article['stockActuel'] ??
        item.article['stock'];
    if (raw is num) return raw.toInt();
    return null;
  }

  double get _total => widget.cart.fold(0, (acc, item) => acc + item.total);

  bool get _canCheckout {
    if (_isConnected) return true;
    return _guestStep == _GuestStep.returning && _returningClientConfirmed;
  }

  Future<void> _transition(_GuestStep next) async {
    await _stepAnim.reverse();
    setState(() => _guestStep = next);
    _stepAnim.forward();
  }

  // ─── résolution email ─────────────────────────────────────────────────

  Future<void> _lookupEmail() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir un e-mail valide')),
      );
      return;
    }

    await _transition(_GuestStep.loading);

    try {
      final client = await ClientsService.findByEmail(email);
      if (client != null) {
        _resolvedClient = client;
        _returningClientConfirmed = false;
        await _transition(_GuestStep.returning);
      } else {
        await _transition(_GuestStep.notFound);
      }
    } catch (_) {
      if (!mounted) return;
      await _transition(_GuestStep.emailEntry);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de vérifier cet e-mail pour le moment'),
        ),
      );
    }
  }

  // ─── modale "Première commande" ───────────────────────────────────────

  Future<void> _openNewClientSheet({String? prefillEmail}) async {
    final payload = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _NewClientSheet(prefillEmail: prefillEmail),
    );

    if (payload == null || !mounted) return;

    setState(() => _sending = true);
    try {
      final client = await ClientsService.findOrCreate(payload);
      _resolvedClient = client;
      _returningClientConfirmed = true;
      await _transition(_GuestStep.returning);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  // ─── passage de commande ──────────────────────────────────────────────

  Future<void> _checkout() async {
    if (widget.cart.isEmpty || _sending) return;

    final confirmed = await _showConfirmDialog();
    if (confirmed != true) return;

    setState(() => _sending = true);
    try {
      final int effectiveClientId = _isConnected
          ? widget.clientId!
          : _resolvedClient!['id'] as int;

      final commentaire = Validators.normalize(_commentaireCtrl.text);
      await CommandesClientsService.create({
        'clientId': effectiveClientId,
        'commentaire': commentaire.isEmpty
            ? 'Commande via application mobile'
            : commentaire,
        'lignes': [
          for (final item in widget.cart)
            {'articleId': item.articleId, 'quantite': item.quantite},
        ],
      });

      if (!mounted) return;
      widget.onClear();
      _commentaireCtrl.clear();

      if (!_isConnected) {
        _resolvedClient = null;
        _returningClientConfirmed = false;
        await _transition(_GuestStep.emailEntry);
        _emailCtrl.clear();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Commande envoyée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<bool?> _showConfirmDialog() {
    final clientLabel = _isConnected
        ? 'Client #${widget.clientId}'
        : (_resolvedClient != null
              ? '${_resolvedClient!['prenom'] ?? ''} ${_resolvedClient!['nom'] ?? ''}'
                    .trim()
              : '');

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la commande'),
        content: Text(
          'Client : $clientLabel\n'
          'Articles : ${widget.cart.length}\n'
          'Total : ${Formatters.money(_total)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  // ─── build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (widget.cart.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Votre panier est vide',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Form(
      key: _formKey,
      autovalidateMode: _autoValidate
          ? AutovalidateMode.always
          : AutovalidateMode.disabled,
      child: Column(
        children: [
          Expanded(child: _buildCartList()),
          const Divider(height: 1),
          _buildBottomPanel(),
        ],
      ),
    );
  }

  // ── liste du panier ───────────────────────────────────────────────────

  Widget _buildCartList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: widget.cart.length,
      itemBuilder: (context, index) {
        final item = widget.cart[index];
        final stock = _stockFor(item);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              title: Text(
                item.designation,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                Formatters.money(item.prixUnitaire) +
                    (stock != null ? ' • Stock : $stock' : ''),
              ),
              leading: IconButton(
                tooltip: 'Retirer',
                icon: const Icon(Icons.remove_circle_outline),
                color: Theme.of(context).colorScheme.error,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _qtyButton(
                              icon: Icons.remove,
                              onTap: () {
                                if (item.quantite > 1) {
                                  item.quantite -= 1;
                                } else {
                                  widget.cart.removeAt(index);
                                }
                                widget.onCartChanged();
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text(
                                '${item.quantite}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _qtyButton(
                              icon: Icons.add,
                              onTap: () {
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
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.money(item.total),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(icon, size: 16),
      ),
    );
  }

  // ── panneau bas ────────────────────────────────────────────────────────

  Widget _buildBottomPanel() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: Theme.of(context).textTheme.titleMedium),
              Text(
                Formatters.money(_total),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // commentaire
          TextFormField(
            controller: _commentaireCtrl,
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Commentaire (optionnel)',
              hintText: 'Ex : Livraison en matinée, appeler avant',
              prefixIcon: Icon(Icons.note_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (v) => Validators.commentaire(v ?? ''),
          ),
          const SizedBox(height: 12),

          // ── identification client (invité uniquement) ──────────────
          if (!_isConnected) ...[
            FadeTransition(opacity: _fadeAnim, child: _buildGuestSection()),
            const SizedBox(height: 12),
          ],

          // ── bouton passer commande ─────────────────────────────────
          if (_canCheckout)
            FilledButton.icon(
              onPressed: _sending ? null : _checkout,
              icon: _sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.shopping_bag_outlined),
              label: Text(_sending ? 'Envoi en cours…' : 'Passer la commande'),
            ),

          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: widget.onClear,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Vider le panier'),
          ),
        ],
      ),
    );
  }

  // ── section invité ─────────────────────────────────────────────────────

  Widget _buildGuestSection() {
    switch (_guestStep) {
      case _GuestStep.emailEntry:
        return _buildEmailEntry();
      case _GuestStep.loading:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(),
          ),
        );
      case _GuestStep.notFound:
        return _buildEmailNotFound();
      case _GuestStep.returning:
        return _buildReturningClient();
    }
  }

  /// Étape 1 — saisie email
  Widget _buildEmailEntry() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeader(
          icon: Icons.person_outline,
          label: 'Identification',
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Votre e-mail',
                  hintText: 'exemple@mail.com',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ),
            const SizedBox(width: 10),
            FilledButton.tonal(
              onPressed: _lookupEmail,
              child: const Text('Continuer'),
            ),
          ],
        ),
      ],
    );
  }

  /// Étape notFound — email non trouvé
  Widget _buildEmailNotFound() {
    final email = _emailCtrl.text.trim();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.tertiaryContainer,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Aucun compte trouvé avec cet e-mail.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(email, style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => _transition(_GuestStep.emailEntry),
                child: const Text("Modifier l'e-mail"),
              ),
              FilledButton.tonal(
                onPressed: () => _openNewClientSheet(prefillEmail: email),
                child: const Text('Première commande'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Étape returning — client retrouvé
  Widget _buildReturningClient() {
    final client = _resolvedClient!;
    final name = '${client['prenom'] ?? ''} ${client['nom'] ?? ''}'.trim();

    if (_returningClientConfirmed) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.secondaryContainer.withOpacity(.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondaryContainer,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty ? client['email'] as String : name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    client['email'] as String? ?? '',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                _resolvedClient = null;
                _returningClientConfirmed = false;
                _transition(_GuestStep.emailEntry);
              },
              child: const Text('Changer'),
            ),
          ],
        ),
      );
    }

    // confirmation identité
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Nous avons trouvé ce client. Est-ce bien vous ?',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name.isEmpty ? client['email'] as String : name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            client['email'] as String? ?? '',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {
                  _resolvedClient = null;
                  _openNewClientSheet(prefillEmail: _emailCtrl.text.trim());
                },
                child: const Text('Non, première commande'),
              ),
              FilledButton(
                onPressed: () =>
                    setState(() => _returningClientConfirmed = true),
                child: const Text("Oui, c'est moi"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Bottom sheet — formulaire nouvelle commande
// ══════════════════════════════════════════════════════════════════════════════

class _NewClientSheet extends StatefulWidget {
  const _NewClientSheet({this.prefillEmail});

  final String? prefillEmail;

  @override
  State<_NewClientSheet> createState() => _NewClientSheetState();
}

class _NewClientSheetState extends State<_NewClientSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  late String _countryCode;
  late CountryRule _country;

  final TextEditingController _nomCtrl = TextEditingController();
  final TextEditingController _prenomCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _telCtrl = TextEditingController();
  final TextEditingController _adresseCtrl = TextEditingController();
  final TextEditingController _villeCtrl = TextEditingController();
  final TextEditingController _cpCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _countryCode = Validators.countries.first.code; // 'FR' par défaut
    _country = Validators.countryByCode(_countryCode);
    _telCtrl.text = _country.dialCode;
    if (widget.prefillEmail != null) {
      _emailCtrl.text = widget.prefillEmail!;
    }
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _emailCtrl.dispose();
    _telCtrl.dispose();
    _adresseCtrl.dispose();
    _villeCtrl.dispose();
    _cpCtrl.dispose();
    super.dispose();
  }

  void _onCountryChanged(String? code) {
    if (code == null) return;
    setState(() {
      _countryCode = code;
      _country = Validators.countryByCode(code);
      _telCtrl.text = _country.dialCode;
      _cpCtrl.clear();
    });
  }

  void _submit() {
    setState(() => _autoValidate = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    Navigator.pop(context, {
      'nom': _nomCtrl.text.trim(),
      'prenom': _prenomCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'telephone': _telCtrl.text.trim(),
      'adresse': _adresseCtrl.text.trim(),
      'ville': _villeCtrl.text.trim(),
      'codePostal': _cpCtrl.text.trim(),
      'pays': _country.name,
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 24),
      child: Form(
        key: _formKey,
        autovalidateMode: _autoValidate
            ? AutovalidateMode.always
            : AutovalidateMode.disabled,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── handle + titre ────────────────────────────────────────
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Première commande',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'Remplissez vos informations pour finaliser votre commande.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),

            // ── contenu scrollable ────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Pays — en premier pour conditionner les validators
                    _label(context, 'Pays'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _countryCode,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: Validators.countries
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.code,
                              child: Text('${c.name} (${c.dialCode})'),
                            ),
                          )
                          .toList(),
                      onChanged: _onCountryChanged,
                    ),
                    const SizedBox(height: 16),

                    // 2. Identité
                    _label(context, 'Identité'),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            ctrl: _prenomCtrl,
                            label: 'Prénom *',
                            validator: (v) => Validators.strictText(
                              v ?? '',
                              'Prénom',
                              required: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _field(
                            ctrl: _nomCtrl,
                            label: 'Nom *',
                            validator: (v) => Validators.strictText(
                              v ?? '',
                              'Nom',
                              required: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _field(
                      ctrl: _emailCtrl,
                      label: 'E-mail *',
                      keyboard: TextInputType.emailAddress,
                      validator: (v) =>
                          Validators.email(v ?? '', required: true),
                    ),
                    const SizedBox(height: 16),

                    // 3. Contact & adresse — validators selon pays choisi
                    _label(context, 'Contact & adresse'),
                    const SizedBox(height: 6),
                    _field(
                      ctrl: _telCtrl,
                      label: 'Téléphone (${_country.dialCode})',
                      keyboard: TextInputType.phone,
                      validator: (v) =>
                          Validators.phoneForCountry(v ?? '', _countryCode),
                    ),
                    const SizedBox(height: 10),
                    _field(
                      ctrl: _adresseCtrl,
                      label: 'Adresse',
                      validator: (v) => Validators.address(v ?? ''),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _field(
                            ctrl: _villeCtrl,
                            label: 'Ville',
                            validator: (v) => Validators.optionalText(
                              v ?? '',
                              'Ville',
                              Validators.maxCityLength,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _field(
                            ctrl: _cpCtrl,
                            label:
                                'Code postal',
                            keyboard: TextInputType.text,
                            validator: (v) => Validators.postalCodeForCountry(
                              v ?? '',
                              _countryCode,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // ── actions fixes en bas ──────────────────────────────────
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check),
              label: const Text('Confirmer mes informations'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      validator: validator,
    );
  }
}

// ── widgets utilitaires ────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
