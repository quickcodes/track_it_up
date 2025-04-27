part of 'tracking_usecases_impl.dart';

// Use case for deleting device info
class DeleteDeviceInfoByDateUseCase extends UseCase<void, DateTime> {
  final TrackingRepository repository;

  DeleteDeviceInfoByDateUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DateTime params) async {
    return executeDBUsecases(() => repository.deleteDeviceInfoByDate(params));
  }
}

  // @override
  // Future<Either<Failure, int>> call(DeviceInfo params) {
  //   return executeDBUsecases(() => repository.addDeviceInfo(params));
  // }