import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _money = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'EUR ',
    decimalDigits: 2,
  );

  static final _date = DateFormat('dd/MM/yyyy HH:mm');

  static String money(num? value) => _money.format(value ?? 0);

  static String dateTime(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    return _date.format(parsed.toLocal());
  }
}
