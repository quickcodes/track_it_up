import 'package:objectbox/objectbox.dart';
import 'package:track_it_up/features/tracking/data/models/device_info_model.dart';
import 'package:track_it_up/features/tracking/domain/entities/battery_status.dart';

@Entity()
class BatteryStatusModel {
  @Id()
  int id = 0;
  final String level;
  final bool charging;
  final String status;
  final deviceInfo = ToOne<DeviceInfoModel>();

  BatteryStatusModel({
    required this.level,
    required this.charging,
    required this.status,
  });


  BatteryStatus toEntity(DeviceInfoModel deviceInfo) {
    final entity = BatteryStatus(
      level: level,
      charging: charging,
      status: status, deviceInfo: deviceInfo,
    );
    return entity;
  }

  static BatteryStatusModel fromEntity(BatteryStatus entity) {
    return BatteryStatusModel(
      level: entity.level,
      charging: entity.charging,
      status: entity.status,
      // deviceInfo: DeviceInfoModel.fromEntity(entity.deviceInfo.target!),
    );
  }

}



