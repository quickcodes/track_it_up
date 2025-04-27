import 'package:track_it_up/core/errors/failure.dart';
import 'package:track_it_up/core/errors/local_db_failures.dart';
import 'package:track_it_up/core/usecase.dart';
import 'package:track_it_up/features/tracking/domain/entities/device_info.dart';
import 'package:track_it_up/features/tracking/domain/repositories/tracking_repository.dart';
import 'package:dartz/dartz.dart';

part 'get_all_device_info_usecase.dart';
part 'add_device_info_usecase.dart';
part 'get_device_info_by_date_usecase.dart';
part 'delete_device_info_usecase.dart';
part 'clear_all_device_info_usecase.dart';
part 'delete_device_info_by_date_usecase.dart';

class TrackingUsecasesImpl {
  final TrackingRepository deviceRepository;
  final AddDeviceInfoUseCase addDeviceInfoUseCase;
  final GetAllDeviceInfoUseCase getAllDeviceInfoUseCase;
  final GetDeviceInfoByDateUseCase getDeviceInfoByDateUseCase;
  final DeleteDeviceInfoUseCase deleteDeviceInfoUseCase;
  final DeleteDeviceInfoByDateUseCase deleteDeviceInfoByDateUseCase;
  final ClearAllDeviceInfoUseCase clearAllDeviceInfoUseCase;

  TrackingUsecasesImpl({
    required this.deviceRepository,
    required this.addDeviceInfoUseCase,
    required this.getAllDeviceInfoUseCase,
    required this.getDeviceInfoByDateUseCase,
    required this.deleteDeviceInfoUseCase,
    required this.deleteDeviceInfoByDateUseCase,
    required this.clearAllDeviceInfoUseCase,
  });

  Future<Either<Failure, List<DeviceInfo>>> addDeviceInfo(
      DeviceInfo deviceInfo) async {
    try {
      await addDeviceInfoUseCase(deviceInfo);
      return await getAllDeviceInfo(); // Return updated list after adding
    } catch (e) {
      throw Exception('Failed to add device info: ${e.toString()}');
    }
  }

  Future<Either<Failure, List<DeviceInfo>>> getAllDeviceInfo() async {
    try {
      return await getAllDeviceInfoUseCase.call(null);
    } catch (e) {
      throw Exception('Failed to fetch device info: ${e.toString()}');
    }
  }

  Future<Either<Failure, List<DeviceInfo>>> getDeviceInfoByDate(
      DateTime date) async {
    try {
      return await getDeviceInfoByDateUseCase.call(date);
    } catch (e) {
      throw Exception('Failed to fetch device info by date: ${e.toString()}');
    }
  }

  Future<Either<Failure, void>> deleteDeviceInfo(int id) async {
    try {
      return await deleteDeviceInfoUseCase.call(id);
    } catch (e) {
      throw Exception('Failed to delete device info: ${e.toString()}');
    }
  }

  Future<Either<Failure, void>> deleteDeviceInfoByDate(DateTime date) async {
    try {
      return await deleteDeviceInfoByDateUseCase.call(date);
    } catch (e) {
      throw Exception('Failed to delete device info by Date: ${e.toString()}');
    }
  }

  Future<Either<Failure, void>> clearAllDeviceInfo() async {
    try {
      return await clearAllDeviceInfoUseCase.call(null);
    } catch (e) {
      throw Exception('Failed to clear all device info: ${e.toString()}');
    }
  }

  Stream<List<DeviceInfo>> watchDeviceInfo() {
    return deviceRepository.watchDeviceInfo();
  }
}

Future<Either<Failure, T>> executeDBUsecases<T>(
    Future<T> Function() action) async {
  try {
    final result = await action();
    return Right(result);
  } on Failure catch (f) {
    return Left(f);
  } catch (e) {
    return Left(UnknownLocalFailure());
  }
}
