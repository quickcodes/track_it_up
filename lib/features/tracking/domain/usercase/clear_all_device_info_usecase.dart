part of 'tracking_usecases_impl.dart';

// Use case for clearing all device info
class ClearAllDeviceInfoUseCase extends UseCase<void, void> {
  final TrackingRepository repository;

  ClearAllDeviceInfoUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(void params) async {
    // try {
    //   await repository.clearAllDeviceInfo();
    //   return const Right(null);
    // } on Failure catch (f) {
    //   return Left(f);
    // } catch (e) {
    //   return Left(UnknownLocalFailure());
    // }
     return executeDBUsecases(() => repository.clearAllDeviceInfo());
  }
}


