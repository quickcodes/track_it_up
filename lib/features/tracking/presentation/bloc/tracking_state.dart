part of 'tracking_bloc.dart';

enum TrackingStatus { initial, success, error, loading, selected }

extension TrackingStatusX on TrackingStatus {
  bool get isInitial => this == TrackingStatus.initial;
  bool get isSuccess => this == TrackingStatus.success;
  bool get isError => this == TrackingStatus.error;
  bool get isLoading => this == TrackingStatus.loading;
  bool get isSelected => this == TrackingStatus.selected;
}

class TrackingState extends Equatable {
  const TrackingState({
    this.status = TrackingStatus.initial,
    this.deviceInfos = const [],
    // this.idSelected = 0,
  });

  final List<DeviceInfo> deviceInfos;
  final TrackingStatus status;
  // final int idSelected;

  @override
  List<Object?> get props => [status, deviceInfos];

  TrackingState copyWith({
    List<DeviceInfo>? deviceInfos,
    TrackingStatus? status,
    // int? idSelected,
  }) {
    return TrackingState(
      deviceInfos: deviceInfos ?? this.deviceInfos,
      status: status ?? this.status,
      // idSelected: idSelected ?? this.idSelected,
    );
  }
}
