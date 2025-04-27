import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track_it_up/features/tracking/presentation/bloc/tracking_bloc.dart';
import 'package:track_it_up/features/tracking/presentation/widgets/device_summary_screen/ds_daily_summary_card.dart';
import 'package:track_it_up/features/tracking/presentation/widgets/device_summary_screen/ds_frequently_visited_place_list.dart';
import 'package:track_it_up/features/tracking/presentation/screens/device_path_map_flutter_map.dart';

class DeviceSummaryScreen extends StatelessWidget {
  const DeviceSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📱 Device Summary'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<TrackingBloc, TrackingState>(
        builder: (context, state) {
          if (state.status == TrackingStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == TrackingStatus.error) {
            return const Center(child: Text('Error loading data.'));
          } else if (state.deviceInfos.isEmpty) {
            return const Center(child: Text('No data available.'));
          }

          final deviceInfoList = state.deviceInfos;

          return ListView(
            padding: const EdgeInsets.only(bottom: 20),
            children: [
              DSDailySummaryCard(deviceInfoList: deviceInfoList),
              DSFrequentVisitedPlacesList(deviceInfoList: deviceInfoList),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DevicePathMapFlutterMap(
                          deviceInfoList: deviceInfoList,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map_outlined),
                  label: const Text(
                    'View Device Path on Map',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
