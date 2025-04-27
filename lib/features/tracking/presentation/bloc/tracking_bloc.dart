import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:track_it_up/features/tracking/domain/entities/device_info.dart';
import 'package:track_it_up/features/tracking/domain/usercase/tracking_usecases_impl.dart';

part 'tracking_event.dart';
part 'tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final TrackingUsecasesImpl trackingUsecases;

  TrackingBloc(this.trackingUsecases) : super(const TrackingState()) {
    on<GetAllDeviceInfoEvent>(_mapGetAllDeviceInfoEventToState);
    on<AddDeviceInfoEvent>(_mapAddDeviceInfoEventToState);
    on<GetDeviceInfoByDateEvent>(_mapGetDeviceInfoByDateEventToState);
    on<DeleteDeviceInfoEvent>(_mapDeleteDeviceInfoEventToState);
    on<ClearAllDeviceInfoEvent>(_mapClearAllDeviceInfoEventToState);
    on<WatchDeviceInfoEvent>(_mapWatchDeviceInfoEventToState);
    on<DeleteDeviceInfoByDateEvent>(_mapDeleteDeviceInfoByDateToState);
  }

  void _mapGetAllDeviceInfoEventToState(
      GetAllDeviceInfoEvent event, Emitter<TrackingState> emit) async {
    emit(state.copyWith(status: TrackingStatus.loading));
    try {
      final result = await trackingUsecases.getAllDeviceInfo();
      // emit(state.copyWith(
      //   status: TrackingStatus.success,
      //   deviceInfos: deviceInfos,
      // ));
      result.fold(
        (failure) => emit(state.copyWith(status: TrackingStatus.error)),
        (deviceInfos) => emit(state.copyWith(
          status: TrackingStatus.success,
          deviceInfos: deviceInfos,
        )),
      );
    } catch (e) {
      emit(state.copyWith(status: TrackingStatus.error));
    }
  }

  void _mapAddDeviceInfoEventToState(
      AddDeviceInfoEvent event, Emitter<TrackingState> emit) async {
    emit(state.copyWith(status: TrackingStatus.loading));
    try {
      // await trackingUsecases.addDeviceInfo(event.deviceInfo);
      // final updatedDeviceInfos = await trackingUsecases.getAllDeviceInfo();
      // emit(state.copyWith(
      //   status: TrackingStatus.success,
      //   deviceInfos: updatedDeviceInfos,
      // ));

      final addResult = await trackingUsecases.addDeviceInfo(event.deviceInfo);
      addResult.fold(
        (failure) => emit(state.copyWith(status: TrackingStatus.error)),
        (_) async {
          final getResult = await trackingUsecases.getAllDeviceInfo();
          getResult.fold(
            (failure) => emit(state.copyWith(status: TrackingStatus.error)),
            (deviceInfos) => emit(state.copyWith(
              status: TrackingStatus.success,
              deviceInfos: deviceInfos,
            )),
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(status: TrackingStatus.error));
    }
  }

  void _mapGetDeviceInfoByDateEventToState(
      GetDeviceInfoByDateEvent event, Emitter<TrackingState> emit) async {
    emit(state.copyWith(status: TrackingStatus.loading));
    try {
      final result = await trackingUsecases.getDeviceInfoByDate(event.date);
      result.fold(
        (failure) => emit(state.copyWith(status: TrackingStatus.error)),
        (deviceInfos) => emit(state.copyWith(
          status: TrackingStatus.success,
          deviceInfos: deviceInfos,
        )),
      );
    } catch (e) {
      emit(state.copyWith(status: TrackingStatus.error));
    }
  }

  void _mapDeleteDeviceInfoEventToState(
      DeleteDeviceInfoEvent event, Emitter<TrackingState> emit) async {
    emit(state.copyWith(status: TrackingStatus.loading));
    try {
      final deleteResult = await trackingUsecases.deleteDeviceInfo(event.id);
      deleteResult.fold(
        (failure) => emit(state.copyWith(status: TrackingStatus.error)),
        (_) async {
          final getResult = await trackingUsecases.getAllDeviceInfo();
          getResult.fold(
            (failure) => emit(state.copyWith(status: TrackingStatus.error)),
            (deviceInfos) => emit(state.copyWith(
              status: TrackingStatus.success,
              deviceInfos: deviceInfos,
            )),
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(status: TrackingStatus.error));
    }
  }

  void _mapClearAllDeviceInfoEventToState(
      ClearAllDeviceInfoEvent event, Emitter<TrackingState> emit) async {
    emit(state.copyWith(status: TrackingStatus.loading));
    try {
      final result = await trackingUsecases.clearAllDeviceInfo();
      result.fold(
        (failure) => emit(state.copyWith(status: TrackingStatus.error)),
        (_) => emit(state.copyWith(
          status: TrackingStatus.success,
          deviceInfos: [],
        )),
      );
    } catch (e) {
      emit(state.copyWith(status: TrackingStatus.error));
    }
  }

  void _mapWatchDeviceInfoEventToState(
      WatchDeviceInfoEvent event, Emitter<TrackingState> emit) async {
    emit(state.copyWith(status: TrackingStatus.loading));
    try {
      await for (final deviceInfos in trackingUsecases.watchDeviceInfo()) {
        emit(state.copyWith(
          status: TrackingStatus.success,
          deviceInfos: deviceInfos,
        ));
      }
    } catch (e) {
      emit(state.copyWith(status: TrackingStatus.error));
    }
  }

void _mapDeleteDeviceInfoByDateToState(
    DeleteDeviceInfoByDateEvent event, Emitter<TrackingState> emit) async {
  emit(state.copyWith(status: TrackingStatus.loading));
  try {
    final deleteResult = await trackingUsecases.deleteDeviceInfoByDate(event.date);
    deleteResult.fold(
      (failure) => emit(state.copyWith(status: TrackingStatus.error)),
      (_) async {
        final getResult = await trackingUsecases.getAllDeviceInfo();
        getResult.fold(
          (failure) => emit(state.copyWith(status: TrackingStatus.error)),
          (deviceInfos) => emit(state.copyWith(
            status: TrackingStatus.success,
            deviceInfos: deviceInfos,
          )),
        );
      },
    );
  } catch (e) {
    emit(state.copyWith(status: TrackingStatus.error));
  }
}

}
