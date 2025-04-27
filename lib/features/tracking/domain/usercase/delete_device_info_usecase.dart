part of 'tracking_usecases_impl.dart';

// Use case for deleting device info
class DeleteDeviceInfoUseCase extends UseCase<bool, int> {
  final TrackingRepository repository;

  DeleteDeviceInfoUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(int params) async {
    return executeDBUsecases(() => repository.deleteDeviceInfo(params));
  }
}

  // @override
  // Future<Either<Failure, int>> call(DeviceInfo params) {
  //   return executeDBUsecases(() => repository.addDeviceInfo(params));
  // }