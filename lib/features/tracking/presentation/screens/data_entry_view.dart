import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track_it_up/features/tracking/presentation/bloc/tracking_bloc.dart';
import 'package:track_it_up/features/tracking/domain/entities/device_info.dart';
import 'package:track_it_up/features/tracking/presentation/widgets/data_entry_view/de_entry_chip_list.dart';
import 'package:track_it_up/features/tracking/presentation/widgets/data_entry_view/de_entry_summary.dart';

class DateEntryView extends StatefulWidget {
  const DateEntryView({super.key});

  @override
  State<DateEntryView> createState() => _DateEntryViewState();
}

class _DateEntryViewState extends State<DateEntryView> {
  @override
  void initState() {
    super.initState();
    context.read<TrackingBloc>().add(GetAllDeviceInfoEvent());
  }

  Map<DateTime, int> groupEntriesByDate(List<DeviceInfo> entries) {
    final Map<DateTime, int> countByDate = {};
    for (var entry in entries) {
      final date = DateTime(
          entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
      countByDate.update(date, (value) => value + 1, ifAbsent: () => 1);
    }
    return countByDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device Entries by Date')),
      body: BlocBuilder<TrackingBloc, TrackingState>(
        builder: (context, state) {
          if (state.status == TrackingStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == TrackingStatus.error) {
            return const Center(child: Text('Error loading data.'));
          } else if (state.deviceInfos.isEmpty) {
            return const Center(child: Text('No data available.'));
          }

          final groupedData = groupEntriesByDate(state.deviceInfos);
          final total = state.deviceInfos.length;

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DEEntrySummary(totalEntries: total),
                const SizedBox(height: 12),
                DEEntryChipList(groupedData: groupedData),
              ],
            ),
          );
        },
      ),
    );
  }
}
