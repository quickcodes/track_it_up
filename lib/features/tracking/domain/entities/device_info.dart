
import 'package:track_it_up/features/tracking/domain/entities/battery_status.dart';

class DeviceInfo {
  int id = 0;
  final String deviceModel;
  final String osVersion;
  final String screenResolution;
  final String deviceUniqueID;
  final BatteryStatus batteryStatus;
  final String networkInformation;

  final double latitude;
  final double longitude;
  final double accuracy;
  final double altitude;
  final double heading;
  final double speed;
  final double speedAccuracy;
  final DateTime timestamp;
  final List<String> nearbyBluetoothDevices;

  DeviceInfo({
    required this.deviceModel,
    required this.osVersion,
    required this.screenResolution,
    required this.deviceUniqueID,
    required this.batteryStatus,
    required this.networkInformation,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.altitude,
    required this.heading,
    required this.speed,
    required this.speedAccuracy,
    required this.timestamp,
    required this.nearbyBluetoothDevices,
  });

  @override
  String toString() {
    return '''Device Model: $deviceModel
OS Version: $osVersion
Screen Resolution: $screenResolution
Unique ID: $deviceUniqueID
Battery: $batteryStatus
Network: $networkInformation
Location: 
  Latitude: $latitude
  Longitude: $longitude
  Accuracy: $accuracy
  Altitude: $altitude
  Heading: $heading
  Speed: $speed
  Speed Accuracy: $speedAccuracy
  Timestamp: $timestamp
Nearby Bluetooth Devices: $nearbyBluetoothDevices''';
  }
}
