part of 'tracking_usecases_impl.dart';

class AddDeviceInfoUseCase extends UseCase<int, DeviceInfo> {
  final TrackingRepository repository;

  AddDeviceInfoUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(DeviceInfo params) {
    return executeDBUsecases(() => repository.addDeviceInfo(params));
  }
}
