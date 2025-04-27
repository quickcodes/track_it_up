part of 'tracking_bloc.dart';

abstract class TrackingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddDeviceInfoEvent extends TrackingEvent {
  final DeviceInfo deviceInfo;

  AddDeviceInfoEvent(this.deviceInfo);

  @override
  List<Object?> get props => [deviceInfo];
}

class GetAllDeviceInfoEvent extends TrackingEvent {}

class GetDeviceInfoByDateEvent extends TrackingEvent {
  final DateTime date;

  GetDeviceInfoByDateEvent(this.date);

  @override
  List<Object?> get props => [date];
}

class DeleteDeviceInfoEvent extends TrackingEvent {
  final int id;

  DeleteDeviceInfoEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ClearAllDeviceInfoEvent extends TrackingEvent {}

class WatchDeviceInfoEvent extends TrackingEvent {}

class DeleteDeviceInfoByDateEvent extends TrackingEvent {
  final DateTime date;
  DeleteDeviceInfoByDateEvent(this.date);
  
  @override
  List<Object?> get props => [date];
}