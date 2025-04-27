import 'package:flutter/material.dart';

class DSSummaryChip extends StatelessWidget {
  final String emoji;
  final String text;

  const DSSummaryChip(this.emoji, this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        '$emoji $text',
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
