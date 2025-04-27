import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track_it_up/features/tracking/presentation/bloc/tracking_bloc.dart';
import 'de_delete_dialog.dart';

class DEEntryChipList extends StatelessWidget {
  final Map<DateTime, int> groupedData;

  const DEEntryChipList({super.key, required this.groupedData});

  void _confirmDelete(BuildContext context, DateTime date) {
    // final formattedDate =
    //     "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";

    deShowDeleteDialog(
      context,
      date,
      groupedData[date] ?? 0,
      () {
        context.read<TrackingBloc>().add(DeleteDeviceInfoByDateEvent(date));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedEntries = groupedData.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: sortedEntries.map((entry) {
        final date = entry.key;
        final count = entry.value;
        final formattedDate =
            "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";

        return InkWell(
          onTap: () => _confirmDelete(context, date),
          child: Chip(
            label: Text(
              '$formattedDate ($count)',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        );
      }).toList(),
    );
  }
}
