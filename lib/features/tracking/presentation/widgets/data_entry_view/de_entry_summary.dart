import 'package:flutter/material.dart';

class DEEntrySummary extends StatelessWidget {
  final int totalEntries;

  const DEEntrySummary({super.key, required this.totalEntries});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Total Entries: $totalEntries',
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}
