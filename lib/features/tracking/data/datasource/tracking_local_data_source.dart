import 'package:track_it_up/core/errors/local_db_failures.dart';
import 'package:track_it_up/features/tracking/data/models/device_info_model.dart';
import 'package:track_it_up/features/tracking/domain/entities/device_info.dart';
import 'package:track_it_up/objectbox.g.dart';

class TrackingLocalDataSource {
  final Box<DeviceInfoModel> deviceInfoStore;

  TrackingLocalDataSource({required this.deviceInfoStore});

  /// Save a new device info record
  Future<int> addDeviceInfo(DeviceInfoModel info) async {
    try {
      return await deviceInfoStore.putAsync(info);
    } catch (_) {
      throw LocalDBInsertFailure();
    }
  }

  /// Get all records
  Future<List<DeviceInfo>> getAllDeviceInfo() async {
    try {
      final all = await deviceInfoStore.getAllAsync();
      return all.map((e) => e.toEntity()).toList();
    } catch (_) {
      throw LocalDBReadFailure();
    }
  }

  /// Get records by specific date
  Future<List<DeviceInfo>> getDeviceInfoByDate(DateTime selectedDate) async {
    try {
      final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      final endOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59, 999);

      final query = deviceInfoStore
          .query(DeviceInfoModel_.timestamp.between(
              startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch))
          .build();

      final results = await query.findAsync();
      query.close();

      results.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return results.map((e) => e.toEntity()).toList();
    } catch (_) {
      throw LocalDBReadFailure(message: "Failed to read records by date.");
    }
  }

  /// Delete a specific record
  Future<bool> deleteDeviceInfo(int id) async {
    try {
      return await deviceInfoStore.removeAsync(id);
    } catch (_) {
      throw LocalDBDeleteFailure();
    }
  }

  
  Future<void> deleteDeviceInfoByDate(DateTime date) async {
  
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    final query = deviceInfoStore
        .query(DeviceInfoModel_.timestamp.between(
          startOfDay.millisecondsSinceEpoch,
          endOfDay.millisecondsSinceEpoch,
        ))
        .build();

    final recordsToDelete = await query.findAsync();
    query.close();

    if (recordsToDelete.isNotEmpty) {
      await deviceInfoStore.removeManyAsync(recordsToDelete.map((e) => e.id).toList());
    }
  }

  /// Clear all records
  Future<void> clearAllDeviceInfo() async {
    try {
      await deviceInfoStore.removeAllAsync();
    } catch (_) {
      throw LocalDBDeleteFailure(message: "Failed to clear all local database records.");
    }
  }

  /// Watch all changes in the box
  Stream<List<DeviceInfo>> watchDeviceInfo() {
    try {
      return deviceInfoStore.query().watch(triggerImmediately: true).map(
            (query) => query.find().map((e) => e.toEntity()).toList(),
          );
    } catch (_) {
      // Since streams can’t throw directly, wrap failure in a stream or log
      return Stream.error(LocalDBReadFailure(message: "Failed to watch local database changes."));
    }
  }
}
