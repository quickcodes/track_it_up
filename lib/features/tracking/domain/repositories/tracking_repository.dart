import 'package:track_it_up/features/tracking/domain/entities/device_info.dart';

abstract class TrackingRepository {
  Future<int> addDeviceInfo(DeviceInfo info);
  Future<List<DeviceInfo>> getAllDeviceInfo();
  Future<List<DeviceInfo>> getDeviceInfoByDate(DateTime selectedDate);
  Future<bool> deleteDeviceInfo(int id);
  Future<void> deleteDeviceInfoByDate(DateTime date);
  Future<void> clearAllDeviceInfo();
  Stream<List<DeviceInfo>> watchDeviceInfo();
}