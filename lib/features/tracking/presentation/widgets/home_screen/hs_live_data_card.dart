import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:track_it_up/features/tracking/presentation/bloc/tracking_bloc.dart';
import 'hs_loading_state.dart';
import 'hs_no_data_state.dart';

class HSLiveDataCard extends StatefulWidget {
  const HSLiveDataCard({super.key});

  @override
  State<HSLiveDataCard> createState() => _HSLiveDataCardState();
}

class _HSLiveDataCardState extends State<HSLiveDataCard> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: BlocConsumer<TrackingBloc, TrackingState>(
          listener: (context, state) {
            if (state.status == TrackingStatus.error) {
              setState(() => isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Error Occurred")),
              );
            } else if (state.status == TrackingStatus.success &&
                state.deviceInfos.isNotEmpty) {
              setState(() => isLoading = false);
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) =>
              //         DeviceSummaryScreen(deviceInfoList: state.deviceInfos),
              //   ),
              // );
            }
          },
          builder: (context, state) {
            if (state.status == TrackingStatus.loading) {
              return const HSLoadingState();
            }

            if (state.status == TrackingStatus.error) {
              return const HSNoDataState();
            }

            final deviceData = state.deviceInfos.isNotEmpty
                ? state.deviceInfos.last.toString()
                : "—";

            final formattedTime = DateFormat.yMMMEd().add_jm().format(
                  DateTime.now(),
                );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📡 Live Device Data',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
                const SizedBox(height: 10),
                Text(formattedTime,
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w400)),
                Text(deviceData,
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w400)),
              ],
            );
          },
        ),
      ),
    );
  }
}
