// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:track_it_up/features/models/device_summary_model.dart';
// import 'package:track_it_up/features/models/frequently_visited_model.dart';
// import 'package:track_it_up/features/screens/device_path_map_flutter_map.dart';
// import '../models/device_info_model.dart';
// import 'package:url_launcher/url_launcher.dart';

// class DeviceSummaryScreen extends StatelessWidget {
//   final List<DeviceInfoModel> deviceInfoList;
//   final DateTime selectedDate;

//   const DeviceSummaryScreen({
//     super.key,
//     required this.deviceInfoList,
//     required this.selectedDate,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final summary = summarizeDeviceInfoData(deviceInfoList);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Device Summary')),
//       body: Column(
//         children: [
//           // 🔹 Daily Summary
//           Card(
//             margin: const EdgeInsets.all(12),
//             elevation: 4,
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text('📊 Daily Summary',
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 8),
//                   Wrap(
//                     spacing: 16,
//                     runSpacing: 4,
//                     children: [
//                       Text('📅 Date: ${summary.date}'),
//                       Text('🧾 Records: ${summary.totalRecords}'),
//                       Text(
//                           '🕒 Start: ${DateFormat('hh:mm a').format(summary.startTime)}'),
//                       Text(
//                           '🏁 End: ${DateFormat('hh:mm a').format(summary.endTime)}'),
//                       Text(
//                           '⏱️ Duration: ${summary.activeDuration.inHours}h ${summary.activeDuration.inMinutes % 60}m'),
//                       Text(
//                           '🚶 Distance: ${summary.totalDistanceKm.toStringAsFixed(2)} km'),
//                       if (summary.minBatteryLevel != null)
//                         Text('🔋 Battery: ${summary.minBatteryLevel}'),
//                       Text('🔌 Charging: ${summary.chargingSessions}x'),
//                       Text('📶 Network: ${summary.networkChanges} changes'),
//                       Text(
//                           '🔵 Bluetooth: ${summary.uniqueBluetoothDevices} devices'),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // 🔹 Frequent Locations (using FutureBuilder)
//           Expanded(
//             child: FutureBuilder<List<FrequentVisit>>(
//               future: getFrequentlyVisitedPlacesWithAddress(
//                 deviceInfoList,
//                 radiusMeters: 500,
//                 minDuration: const Duration(minutes: 45),
//               ),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(
//                     child: Padding(
//                       padding: EdgeInsets.all(24.0),
//                       child: CircularProgressIndicator(),
//                     ),
//                   );
//                 } else if (snapshot.hasError) {
//                   return Center(
//                     child: Text('❌ Error: ${snapshot.error}'),
//                   );
//                 }

//                 final frequentPlaces = snapshot.data!;
//                 if (frequentPlaces.isEmpty) {
//                   return const Center(
//                     child: Text(
//                       'No frequent places found (min 45 mins stay).',
//                       style: TextStyle(fontSize: 16),
//                     ),
//                   );
//                 }

//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Padding(
//                       padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
//                       child: Text(
//                         '📌 Frequently Visited Places',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: ListView.builder(
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                         itemCount: frequentPlaces.length,
//                         itemBuilder: (context, index) {
//                           final place = frequentPlaces[index];
//                           return Card(
//                             elevation: 3,
//                             margin: const EdgeInsets.symmetric(vertical: 8),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: ListTile(
//                               leading: const Icon(Icons.place,
//                                   color: Colors.deepPurple),
//                               title: Text(
//                                 place.address ?? '📍 Loading address...',
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.w500),
//                               ),
//                               subtitle: Text(
//                                 '🕓 Stayed approx. ${formatDurationInMinutes(place.duration.inMinutes)} mins',
//                                 style: TextStyle(color: Colors.grey[700]),
//                               ),
//                               trailing:
//                                   const Icon(Icons.arrow_forward_ios, size: 16),
//                               // onTap: () {
//                               //   // Optionally show it on a map or with more detail

//                               //   showDialog(
//                               //     context: context,
//                               //     builder: (_) => AlertDialog(
//                               //       title: const Text('Location Info'),
//                               //       content: Text(
//                               //         'Address:\n${place.address ?? 'Unknown'}\n\nTime spent: ${formatDurationInMinutes(place.duration.inMinutes)} minutes\nCoordinates: ${place.location.latitude}, ${place.location.longitude}',
//                               //       ),
//                               //     ),
//                               //   );
//                               // },
//                               onTap: () {
//                                 openInGoogleMaps(place.location.latitude,
//                                     place.location.longitude);
//                               },
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),

//           // 🔘 View Map Button
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: ElevatedButton.icon(
//               style: ElevatedButton.styleFrom(
//                   minimumSize: const Size.fromHeight(50)),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => DevicePathMapFlutterMap(
//                       deviceInfoList: deviceInfoList,
//                       dateToShowData: selectedDate,
//                     ),
//                   ),
//                 );
//               },
//               icon: const Icon(Icons.map),
//               label: const Text('View Device Path on Map'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> openInGoogleMaps(double latitude, double longitude) async {
//     final googleMapsUrl = Uri.parse(
//         'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

//     if (await canLaunchUrl(googleMapsUrl)) {
//       await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
//     } else {
//       throw 'Could not launch Google Maps';
//     }
//   }

//   String formatDurationInMinutes(int totalMinutes) {
//     if (totalMinutes < 60) {
//       return '$totalMinutes mins';
//     }

//     final hours = totalMinutes ~/ 60;
//     final minutes = totalMinutes % 60;

//     if (minutes == 0) {
//       return '$hours ${hours == 1 ? 'hr' : 'hrs'}';
//     }

//     return '$hours ${hours == 1 ? 'hr' : 'hrs'} $minutes mins';
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:track_it_up/features/models/device_summary_model.dart';
import 'package:track_it_up/features/models/frequently_visited_model.dart';
import 'package:track_it_up/features/screens/device_path_map_flutter_map.dart';
import '../models/device_info_model.dart';
import 'package:url_launcher/url_launcher.dart';

class DeviceSummaryScreen extends StatelessWidget {
  final List<DeviceInfoModel> deviceInfoList;
  final DateTime selectedDate;

  const DeviceSummaryScreen({
    super.key,
    required this.deviceInfoList,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final summary = summarizeDeviceInfoData(deviceInfoList);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📱 Device Summary'),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        primary: true,
        shrinkWrap: false,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // 🔹 Daily Summary
          Card(
            margin: const EdgeInsets.all(12),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📊 Daily Summary',
                    style: theme.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 10,
                    children: [
                      _buildSummaryChip('📅', 'Date: ${summary.date}'),
                      _buildSummaryChip(
                          '📊', 'Records: ${summary.totalRecords}'),
                      _buildSummaryChip('🕒',
                          'Start: ${DateFormat('hh:mm a').format(summary.startTime)}'),
                      _buildSummaryChip('🏁',
                          'End: ${DateFormat('hh:mm a').format(summary.endTime)}'),
                      _buildSummaryChip('⏱️',
                          'Duration: ${summary.activeDuration.inHours}h ${summary.activeDuration.inMinutes % 60}m'),
                      _buildSummaryChip('🚶',
                          'Distance: ${summary.totalDistanceKm.toStringAsFixed(2)} km'),
                      if (summary.minBatteryLevel != null)
                        _buildSummaryChip(
                            '🔋', 'Battery: ${summary.minBatteryLevel}'),
                      _buildSummaryChip(
                          '🔌', 'Charging: ${summary.chargingSessions}x'),
                      _buildSummaryChip(
                          '📶', 'Network: ${summary.networkChanges} changes'),
                      _buildSummaryChip('🔵',
                          'Bluetooth: ${summary.uniqueBluetoothDevices} devices'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 🔹 Frequently Visited Places
          FutureBuilder<List<FrequentVisit>>(
            future: getFrequentlyVisitedPlacesWithAddress(
              deviceInfoList,
              radiusMeters: 500,
              minDuration: const Duration(minutes: 45),
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    '❌ Error loading locations',
                    style: theme.textTheme.bodyLarge!
                        .copyWith(color: Colors.redAccent),
                  ),
                );
              }

              final frequentPlaces = snapshot.data ?? [];

              if (frequentPlaces.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No frequent places found.\n(Min 45 mins stay required)',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      '📌 Frequently Visited Places',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ListView.separated(
                    primary: false,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: frequentPlaces.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final place = frequentPlaces[index];

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: ListTile(
                          leading: const Icon(Icons.location_on_rounded,
                              color: Colors.deepPurple, size: 28),
                          title: Text(
                            place.address ?? '📍 Loading address...',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '🕓 Stayed for ${formatDurationInMinutes(place.duration.inMinutes)}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded,
                              size: 16),
                          onTap: () {
                            openInGoogleMaps(place.location.latitude,
                                place.location.longitude);
                          },
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),

          // 🔘 View Map Button
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
                      dateToShowData: selectedDate,
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
      ),
    );
  }

  // Chip-like display for summary info
  Widget _buildSummaryChip(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        '$emoji $text',
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Future<void> openInGoogleMaps(double latitude, double longitude) async {
    final googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch Google Maps';
    }
  }

  String formatDurationInMinutes(int totalMinutes) {
    if (totalMinutes < 60) return '$totalMinutes mins';
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return minutes == 0
        ? '$hours ${hours == 1 ? 'hr' : 'hrs'}'
        : '$hours ${hours == 1 ? 'hr' : 'hrs'} $minutes mins';
  }
}
