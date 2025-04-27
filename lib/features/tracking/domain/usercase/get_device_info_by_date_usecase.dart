part of 'tracking_usecases_impl.dart';

// Use case for getting device info by date
class GetDeviceInfoByDateUseCase extends UseCase<List<DeviceInfo>, DateTime> {
  final TrackingRepository repository;

  GetDeviceInfoByDateUseCase(this.repository);

  @override
  Future<Either<Failure, List<DeviceInfo>>> call(DateTime params) async {
    return executeDBUsecases(() => repository.getDeviceInfoByDate(params));
  }
}