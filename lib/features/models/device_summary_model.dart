import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../models/device_info_model.dart';

class DeviceSummary {
  final String date;
  final int totalRecords;
  final DateTime startTime;
  final DateTime endTime;
  final Duration activeDuration;
  final double totalDistanceKm;
  final LatLng? mostVisitedLocation;
  final Duration? longestStopDuration;
  final String? minBatteryLevel;
  final int chargingSessions;
  final int networkChanges;
  final int uniqueBluetoothDevices;

  DeviceSummary({
    required this.date,
    required this.totalRecords,
    required this.startTime,
    required this.endTime,
    required this.activeDuration,
    required this.totalDistanceKm,
    required this.mostVisitedLocation,
    required this.longestStopDuration,
    required this.minBatteryLevel,
    required this.chargingSessions,
    required this.networkChanges,
    required this.uniqueBluetoothDevices,
  });

  @override
  String toString() {
    return '''
📅 Date: $date
📊 Total Records: $totalRecords
⏱️ Start Time: ${DateFormat('hh:mm:ss a').format(startTime)}
🕔 End Time: ${DateFormat('hh:mm:ss a').format(endTime)}
⏳ Active Duration: ${activeDuration.inHours}h ${activeDuration.inMinutes % 60}m
🚶 Distance Traveled: ${totalDistanceKm.toStringAsFixed(2)} km
📍 Most Visited Location: ${mostVisitedLocation?.latitude}, ${mostVisitedLocation?.longitude}
🛑 Longest Stop: ${longestStopDuration?.inMinutes} min
🔋 Min Battery Level: $minBatteryLevel
🔌 Charging Sessions: $chargingSessions
📶 Network Changes: $networkChanges
🔵 Bluetooth Devices: $uniqueBluetoothDevices
''';
  }
}

DeviceSummary summarizeDeviceInfoData(List<DeviceInfoModel> list) {
  if (list.isEmpty) {
    throw Exception("Device info list is empty.");
  }

  final sorted = List<DeviceInfoModel>.from(list)
    ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

  final startTime = sorted.first.timestamp;
  final endTime = sorted.last.timestamp;
  final activeDuration = endTime.difference(startTime);

  // Distance calculation
  final distance = Distance();
  double totalDistance = 0.0;
  for (int i = 0; i < sorted.length - 1; i++) {
    totalDistance += distance.as(
      LengthUnit.Kilometer,
      LatLng(sorted[i].latitude, sorted[i].longitude),
      LatLng(sorted[i + 1].latitude, sorted[i + 1].longitude),
    );
  }

  // Most visited location (by rounding lat/lng and grouping)
  Map<String, int> locationFrequency = {};
  for (var entry in sorted) {
    final rounded = '${entry.latitude.toStringAsFixed(4)},${entry.longitude.toStringAsFixed(4)}';
    locationFrequency[rounded] = (locationFrequency[rounded] ?? 0) + 1;
  }
  final mostVisited = locationFrequency.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  final latLngParts = mostVisited.split(',').map(double.parse).toList();
  final mostVisitedLocation = LatLng(latLngParts[0], latLngParts[1]);

  // Longest stop duration
  Duration? longestStop;
  for (int i = 1; i < sorted.length; i++) {
    final dist = distance(
      LatLng(sorted[i].latitude, sorted[i].longitude),
      LatLng(sorted[i - 1].latitude, sorted[i - 1].longitude),
    );
    if (dist < 20) { // If distance < 20 meters, consider stationary
      final stopDuration = sorted[i].timestamp.difference(sorted[i - 1].timestamp);
      if (longestStop == null || stopDuration > longestStop) {
        longestStop = stopDuration;
      }
    }
  }

  // Battery stats
  String? minBattery;
  int chargingSessions = 0;
  String? lastStatus;
  for (var info in sorted) {
    final battery = info.batteryStatus.target;
    if (battery != null) {
      final level = int.tryParse(battery.level.replaceAll('%', '')) ?? 100;
      if (minBattery == null || level < int.parse(minBattery.replaceAll('%', ''))) {
        minBattery = battery.level;
      }

      if (lastStatus != null && battery.charging.toString() != lastStatus) {
        chargingSessions++;
      }
      lastStatus = battery.charging.toString();
    }
  }

  // Network changes
  String? lastNetwork;
  int networkChanges = 0;
  for (var info in sorted) {
    if (info.networkInformation != lastNetwork) {
      if (lastNetwork != null) networkChanges++;
      lastNetwork = info.networkInformation;
    }
  }

  // Bluetooth devices
  final btDevices = <String>{};
  for (var info in sorted) {
    btDevices.addAll(info.nearbyBluetoothDevices);
  }

  return DeviceSummary(
    date: DateFormat('yyyy-MM-dd').format(startTime),
    totalRecords: sorted.length,
    startTime: startTime,
    endTime: endTime,
    activeDuration: activeDuration,
    totalDistanceKm: totalDistance,
    mostVisitedLocation: mostVisitedLocation,
    longestStopDuration: longestStop,
    minBatteryLevel: minBattery,
    chargingSessions: chargingSessions,
    networkChanges: networkChanges,
    uniqueBluetoothDevices: btDevices.length,
  );
}
