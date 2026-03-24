import 'package:flutter/material.dart';

Future<bool> confirmDelete(BuildContext context, String label) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Confirmation'),
        content: Text('Supprimer $label ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

void showAppMessage(
  BuildContext context,
  String message, {
  bool error = false,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: error ? Colors.red.shade700 : null,
    ),
  );
}

Widget buildPaginationFooter({
  required int currentPage,
  required int totalPages,
  required int totalItems,
  required int startItem,
  required int endItem,
  required VoidCallback? onPrevious,
  required VoidCallback? onNext,
}) {
  if (totalItems == 0 || totalPages <= 1) {
    return const SizedBox.shrink();
  }

  return Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Elements $startItem-$endItem sur $totalItems',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPrevious,
                icon: const Icon(Icons.chevron_left),
                label: const Text('Precedent'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('Page ${currentPage + 1}/$totalPages'),
            ),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right),
                label: const Text('Suivant'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
