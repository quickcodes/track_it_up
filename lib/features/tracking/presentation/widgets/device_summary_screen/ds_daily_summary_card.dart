import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:track_it_up/features/tracking/domain/entities/device_info.dart';
import 'package:track_it_up/features/tracking/domain/entities/device_summary.dart';
import 'package:track_it_up/features/tracking/presentation/widgets/device_summary_screen/ds_summary_chip.dart';

class DSDailySummaryCard extends StatelessWidget {
  final List<DeviceInfo> deviceInfoList;

  const DSDailySummaryCard({super.key, required this.deviceInfoList});

  @override
  Widget build(BuildContext context) {
    final summary = summarizeDeviceInfoData(deviceInfoList);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📊 Daily Summary',
                style: theme.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                )),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 10,
              children: [
                DSSummaryChip('📅', 'Date: ${summary.date}'),
                DSSummaryChip('📊', 'Records: ${summary.totalRecords}'),
                DSSummaryChip('🕒',
                    'Start: ${DateFormat('hh:mm a').format(summary.startTime)}'),
                DSSummaryChip('🏁',
                    'End: ${DateFormat('hh:mm a').format(summary.endTime)}'),
                DSSummaryChip('⏱️',
                    'Duration: ${summary.activeDuration.inHours}h ${summary.activeDuration.inMinutes % 60}m'),
                DSSummaryChip('🚶',
                    'Distance: ${summary.totalDistanceKm.toStringAsFixed(2)} km'),
                if (summary.minBatteryLevel != null)
                  DSSummaryChip('🔋', 'Battery: ${summary.minBatteryLevel}'),
                DSSummaryChip('🔌', 'Charging: ${summary.chargingSessions}x'),
                DSSummaryChip(
                    '📶', 'Network: ${summary.networkChanges} changes'),
                DSSummaryChip('🔵',
                    'Bluetooth: ${summary.uniqueBluetoothDevices} devices'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
