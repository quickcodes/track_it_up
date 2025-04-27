part of 'tracking_usecases_impl.dart';

class GetAllDeviceInfoUseCase extends UseCase<List<DeviceInfo>, void> {
  final TrackingRepository repository;

  GetAllDeviceInfoUseCase(this.repository);

  @override
  Future<Either<Failure, List<DeviceInfo>>> call(void params) async {
    return executeDBUsecases(() => repository.getAllDeviceInfo());
  }
}
