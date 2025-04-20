import 'package:flutter/material.dart';
import 'package:track_it_up/main.dart';
import 'package:track_it_up/objectbox.g.dart';
import '../models/device_info_model.dart';

class DateEntryWrapView extends StatefulWidget {
  const DateEntryWrapView({super.key});

  @override
  State<DateEntryWrapView> createState() => _DateEntryWrapViewState();
}

class _DateEntryWrapViewState extends State<DateEntryWrapView> {
  late Future<Map<DateTime, int>> _groupedDataFuture;
  int _totalEntries = 0;

  @override
  void initState() {
    super.initState();
    _groupedDataFuture = fetchGroupedData();
  }

  Future<Map<DateTime, int>> fetchGroupedData() async {
    final store = await getStore();
    final box = store.box<DeviceInfoModel>();
    final allData = await box.getAllAsync();

    final Map<DateTime, int> countByDate = {};
    _totalEntries = allData.length;
    if (mounted) {
      setState(() {});
    }
    for (var item in allData) {
      final dateOnly = DateTime(
          item.timestamp.year, item.timestamp.month, item.timestamp.day);
      countByDate.update(dateOnly, (value) => value + 1, ifAbsent: () => 1);
    }

    return countByDate;
  }

  Future<void> deleteRecordsForDate(DateTime date) async {
    final store = await getStore();
    final box = store.box<DeviceInfoModel>();

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    final query = box
        .query(DeviceInfoModel_.timestamp.between(
          startOfDay.millisecondsSinceEpoch,
          endOfDay.millisecondsSinceEpoch,
        ))
        .build();

    final recordsToDelete = await query.findAsync();
    query.close();

    if (recordsToDelete.isNotEmpty) {
      await box.removeManyAsync(recordsToDelete.map((e) => e.id).toList());
    }

    setState(() {
      _groupedDataFuture = fetchGroupedData(); // Refresh
    });
  }

  void _confirmDelete(DateTime date, int count) {
    final formattedDate =
        "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entries'),
        content: Text(
            'Are you sure you want to delete $count entries for $formattedDate?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop(); // Close dialog
              await deleteRecordsForDate(date);
            },
            child: const Text('OK', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device Entries by Date')),
      body: FutureBuilder<Map<DateTime, int>>(
        future: _groupedDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          final groupedData = snapshot.data!;
          final sortedEntries = groupedData.entries.toList()
            ..sort((a, b) => b.key.compareTo(a.key));

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Entries: $_totalEntries',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: sortedEntries.map((entry) {
                    final formattedDate =
                        "${entry.key.day.toString().padLeft(2, '0')}-${entry.key.month.toString().padLeft(2, '0')}-${entry.key.year}";
                    return InkWell(
                      onTap: () => _confirmDelete(entry.key, entry.value),
                      child: Chip(
                        label: Text(
                          '$formattedDate (${entry.value})',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.deepPurple.shade500,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
