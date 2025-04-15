import 'package:objectbox/objectbox.dart';

@Entity()
class DeviceInfoModel {
  @Id()
  int id = 0;
  // Device Info
  final String deviceModel;
  final String osVersion;
  final String screenResolution;
  final String deviceUniqueID;
  // final BatteryStatus batteryStatus;
  final batteryStatus = ToOne<BatteryStatus>();
  final String networkInformation;

  // Location Info
  final double latitude;
  final double longitude;
  final double accuracy;
  final double altitude;
  final double heading;
  final double speed;
  final double speedAccuracy;
  @Property(type: PropertyType.date)
  final DateTime timestamp;
  final List<String> nearbyBluetoothDevices;

  DeviceInfoModel({
    required this.deviceModel,
    required this.osVersion,
    required this.screenResolution,
    required this.deviceUniqueID,
    // required this.batteryStatus,
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
    return '''
Device Model: $deviceModel
OS Version: $osVersion
Screen Resolution: $screenResolution
Unique ID: $deviceUniqueID
Battery: ${batteryStatus.target}
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
Nearby Bluetooth Devices: $nearbyBluetoothDevices
''';
  }
}

@Entity()
class BatteryStatus {
  @Id()
  int id = 0;
  final String level;
  final bool charging;
  final String status;
  final deviceInfo = ToOne<DeviceInfoModel>();

  BatteryStatus({
    required this.level,
    required this.charging,
    required this.status,
  });

  @override
  String toString() {
    return 'Level: $level, Charging: $charging';
  }
}
