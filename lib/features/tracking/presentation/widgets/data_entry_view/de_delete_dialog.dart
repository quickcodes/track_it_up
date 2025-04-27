import 'package:flutter/material.dart';

void deShowDeleteDialog(
    BuildContext context, DateTime date, int count, VoidCallback onConfirm) {
  final formattedDate =
      "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete Entries'),
      content: Text('Delete $count entries for $formattedDate?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            onConfirm();
          },
          child: const Text('OK', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
