import 'package:track_it_up/features/tracking/data/datasource/tracking_local_data_source.dart';
import 'package:track_it_up/features/tracking/data/models/device_info_model.dart';
import 'package:track_it_up/features/tracking/domain/entities/device_info.dart';
import 'package:track_it_up/features/tracking/domain/repositories/tracking_repository.dart';


class TrackingRepositoryImpl implements TrackingRepository {
  final TrackingLocalDataSource dataSource;

  TrackingRepositoryImpl({required this.dataSource});

  @override
  Future<int> addDeviceInfo(DeviceInfo info) async {
    return await dataSource.addDeviceInfo(DeviceInfoModel.fromEntity(info));
  }

  @override
  Future<List<DeviceInfo>> getAllDeviceInfo() async {
    return await dataSource.getAllDeviceInfo();
  }

  @override
  Future<List<DeviceInfo>> getDeviceInfoByDate(DateTime selectedDate) async {
    return await dataSource.getDeviceInfoByDate(selectedDate);
  }

  @override
  Future<bool> deleteDeviceInfo(int id) async {
    return await dataSource.deleteDeviceInfo(id);
  }

  @override
  Future<void> deleteDeviceInfoByDate(DateTime date) async {
    return await dataSource.deleteDeviceInfoByDate(date);
  }

  @override
  Future<void> clearAllDeviceInfo() async {
    await dataSource.clearAllDeviceInfo();
  }

  @override
  Stream<List<DeviceInfo>> watchDeviceInfo() {
    return dataSource.watchDeviceInfo();
  }
}
