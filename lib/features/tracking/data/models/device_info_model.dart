import 'package:objectbox/objectbox.dart';
import 'package:track_it_up/features/tracking/data/models/battery_status_model.dart';
import 'package:track_it_up/features/tracking/domain/entities/device_info.dart';

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
  final batteryStatus = ToOne<BatteryStatusModel>();
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



  DeviceInfo toEntity() {
    final battery = batteryStatus.target?.toEntity(this);
    final entity = DeviceInfo(
      deviceModel: deviceModel,
      osVersion: osVersion,
      screenResolution: screenResolution,
      deviceUniqueID: deviceUniqueID,
      networkInformation: networkInformation,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      altitude: altitude,
      heading: heading,
      speed: speed,
      speedAccuracy: speedAccuracy,
      timestamp: timestamp,
      nearbyBluetoothDevices: nearbyBluetoothDevices, batteryStatus: battery!,
    );

    // entity.batteryStatus.target = battery;
    // battery.deviceInfo.target = entity;
    return entity;
  }

  static DeviceInfoModel fromEntity(DeviceInfo entity) {
    // final battery = entity.batteryStatus.target!;
    return DeviceInfoModel(
      deviceModel: entity.deviceModel,
      osVersion: entity.osVersion,
      screenResolution: entity.screenResolution,
      deviceUniqueID: entity.deviceUniqueID,
      // batteryStatus: BatteryStatus.fromEntity(battery),
      networkInformation: entity.networkInformation,
      latitude: entity.latitude,
      longitude: entity.longitude,
      accuracy: entity.accuracy,
      altitude: entity.altitude,
      heading: entity.heading,
      speed: entity.speed,
      speedAccuracy: entity.speedAccuracy,
      timestamp: entity.timestamp,
      nearbyBluetoothDevices: entity.nearbyBluetoothDevices,
    );
  }

}

