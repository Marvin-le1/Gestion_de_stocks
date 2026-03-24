import '../../../core/utils/types.dart';

class CartItem {
  CartItem({required this.article, required this.quantite});

  final JsonMap article;
  int quantite;

  double get prixUnitaire => (article['prixUnitaire'] as num?)?.toDouble() ?? 0;

  int get articleId => article['id'] as int;

  String get designation => (article['designation'] as String?) ?? 'Article';

  double get total => prixUnitaire * quantite;
}
