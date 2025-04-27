

import 'package:track_it_up/features/tracking/data/models/device_info_model.dart';

class BatteryStatus {
  int id = 0;
  final String level;
  final bool charging;
  final String status;
  final DeviceInfoModel? deviceInfo;

  BatteryStatus({
    required this.level,
    required this.charging,
    required this.status,
    this.deviceInfo,
  });

  @override
  String toString() {
    return 'Level: $level, Charging: $charging';
  }
}
