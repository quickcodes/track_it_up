import 'dart:async';
import 'dart:developer';

import 'package:get_it/get_it.dart';
import 'package:objectbox/objectbox.dart';
import 'package:track_it_up/core/services/local_db_service.dart';
import 'package:track_it_up/features/tracking/data/datasource/tracking_local_data_source.dart';
import 'package:track_it_up/features/tracking/data/models/device_info_model.dart';
import 'package:track_it_up/features/tracking/data/repositories/tracking_repository_impl.dart';
import 'package:track_it_up/features/tracking/domain/repositories/tracking_repository.dart';
import 'package:track_it_up/features/tracking/domain/usercase/tracking_usecases_impl.dart';
import 'package:track_it_up/features/tracking/presentation/bloc/tracking_bloc.dart'; // Your ObjectBox import

final getIt = GetIt.instance;
late final Admin admin;


/// Completer and ObjectBox initialization
final Completer<Store> _storeCompleter = Completer<Store>();

Future<void> initStore() async {
  if (!_storeCompleter.isCompleted) {
    final store = await ObjectBox.create();
    _storeCompleter.complete(store.store);
  }
}

Future<Store> getStore() async {
  if (!_storeCompleter.isCompleted) {
    await initStore(); // Lazy init
  }
  return _storeCompleter.future;
}

/// Initialize get_it with the store
Future<void> initGetIt() async {
  // getIt.registerLazySingleton<Future<Store>>(() async {
  //   await initStore();
  //   return getStore();
  // });
  try {

  //* Database
  getIt.registerSingletonAsync<Store>(() async {
    await initStore();
    return getStore();
  });

  //* Wait until all async singletons are ready
  await getIt.allReady();



    getIt
      //* DataSource
      ..registerSingleton<TrackingLocalDataSource>(
          TrackingLocalDataSource(deviceInfoStore: getIt<Store>().box<DeviceInfoModel>()))

      //* Repository
      ..registerSingleton<TrackingRepository>(
          TrackingRepositoryImpl(dataSource: getIt<TrackingLocalDataSource>()))

      //* UseCases
      ..registerSingleton<TrackingUsecasesImpl>(TrackingUsecasesImpl(
        deviceRepository: getIt<TrackingRepository>(),
        addDeviceInfoUseCase: AddDeviceInfoUseCase(getIt<TrackingRepository>()),
        getAllDeviceInfoUseCase: GetAllDeviceInfoUseCase(getIt<TrackingRepository>()),
        getDeviceInfoByDateUseCase: GetDeviceInfoByDateUseCase(getIt<TrackingRepository>()),
        deleteDeviceInfoUseCase: DeleteDeviceInfoUseCase(getIt<TrackingRepository>()),
        deleteDeviceInfoByDateUseCase: DeleteDeviceInfoByDateUseCase(getIt<TrackingRepository>()),
        clearAllDeviceInfoUseCase: ClearAllDeviceInfoUseCase(getIt<TrackingRepository>()),
      ))

      //* BloC
      ..registerFactory<TrackingBloc>(
          () => TrackingBloc(getIt<TrackingUsecasesImpl>()))
      
      //* End Initialization
      ;

    //* Preview DATABASE Locally
    if (Admin.isAvailable()) {
      admin = Admin(getIt<ObjectBox>().store);
      log("Admin is available on Local Device at http://127.0.0.1:8090");
    } else {
      log("Admin is not available");
    }
  } catch (e, stackTrace) {
    log("Dependency Injection failed: $e", stackTrace: stackTrace);
    rethrow;
  }

}
