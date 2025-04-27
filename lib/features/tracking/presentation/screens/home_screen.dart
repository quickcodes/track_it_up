// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:track_it_up/features/tracking/domain/entities/device_info.dart';
// import 'package:track_it_up/features/tracking/presentation/bloc/tracking_bloc.dart';

// import 'device_summary_screen.dart';
// import 'data_entry_view.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   bool isLoading = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('📡 Background Service Monitor'),
//         centerTitle: true,
//         elevation: 2,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: ListView(
//           children: [
//             // 🔄 Live Data from StreamBuilder
//             Card(
//               elevation: 6,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(10),
//                 child: BlocConsumer<TrackingBloc, TrackingState>(
//                   listener: (BuildContext context, TrackingState state) {
//                     if (state.status == TrackingStatus.error) {
//                       const snackBar = SnackBar(content: Text("Error Occured"));

//                       setState(() {
//                         isLoading = false;
//                       });

//                       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                     }
//                     if (state.status == TrackingStatus.success &&
//                         state.deviceInfos.isNotEmpty) {
//                       setState(() {
//                         isLoading = false;
//                       });
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => DeviceSummaryScreen(
//                               deviceInfoList: state.deviceInfos),
//                         ),
//                       );
//                     }
//                   },
//                   builder: (context, state) {
//                     if (state.status == TrackingStatus.loading) {
//                       return _buildLoadingState();
//                     }

//                     if (state.status == TrackingStatus.error) {
//                       return _buildNoDataState();
//                     }

//                     final deviceData = state.deviceInfos.isNotEmpty
//                         ? state.deviceInfos.last.deviceModel
//                         : "—";
//                     final timestamp = DateTime.now();
//                     final formattedTime =
//                         DateFormat.yMMMEd().add_jm().format(timestamp);

//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           '📡 Live Device Data',
//                           style:
//                               Theme.of(context).textTheme.titleMedium?.copyWith(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 18,
//                                   ),
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           formattedTime,
//                           style: const TextStyle(
//                             fontSize: 10,
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),
//                         Text(
//                           deviceData,
//                           style: const TextStyle(
//                             fontSize: 10,
//                             fontWeight: FontWeight.w400,
//                           ),
//                         )
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ),

//             const SizedBox(height: 15),

//             // 📅 View Coordinates by Date Button
//             ElevatedButton.icon(
//               icon: isLoading
//                   ? const SizedBox(
//                       height: 15,
//                       width: 15,
//                       child: CircularProgressIndicator(
//                         color: Colors.white,
//                         strokeWidth: 2,
//                       ),
//                     )
//                   : const Icon(Icons.calendar_today),
//               label: const Text("View Coordinates by Date"),
//               onPressed: () async {
//                 if (isLoading) return;
//                 final DateTime? selectedDate = await showDatePicker(
//                   context: context,
//                   initialDate: DateTime.now(),
//                   firstDate: DateTime(2020),
//                   lastDate: DateTime.now(),
//                 );

//                 if (selectedDate != null) {
//                   setState(() {
//                     isLoading = true;
//                   });
//                   if (context.mounted) {
//                     context.read<TrackingBloc>().add(
//                           GetDeviceInfoByDateEvent(selectedDate),
//                         );
//                   }
//                 }
//               },
//             ),

//             const SizedBox(height: 15),

//             // View Records Button
//             ElevatedButton.icon(
//               icon: const Icon(Icons.date_range),
//               label: const Text("View Records"),
//               onPressed: () {
//                 Navigator.of(context).push(MaterialPageRoute(
//                   builder: (context) => const DateEntryView(),
//                 ));
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // 🔹 Filter and sort data by date
//   List<DeviceInfo> getFilteredAndSortedData(
//       List<DeviceInfo> deviceInfoList, DateTime selectedDate) {
//     final filtered = deviceInfoList
//         .where((e) =>
//             e.timestamp.year == selectedDate.year &&
//             e.timestamp.month == selectedDate.month &&
//             e.timestamp.day == selectedDate.day)
//         .toList();

//     filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
//     return filtered;
//   }

//   Widget _buildLoadingState() {
//     return const Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         CircularProgressIndicator(),
//         SizedBox(height: 20),
//         Text(
//           "Waiting for live data...",
//           style: TextStyle(
//             fontSize: 16,
//             color: Colors.grey,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildNoDataState() {
//     return const Column(
//       children: [
//         Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
//         SizedBox(height: 12),
//         Text(
//           "No data received.",
//           style: TextStyle(fontSize: 16, color: Colors.black54),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:track_it_up/features/tracking/presentation/widgets/home_screen/hs_date_button.dart';
import 'package:track_it_up/features/tracking/presentation/widgets/home_screen/hs_live_data_card.dart';
import 'package:track_it_up/features/tracking/presentation/widgets/home_screen/hs_records_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📡 Background Service Monitor'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            HSLiveDataCard(),
            SizedBox(height: 15),
            HSDateButton(),
            SizedBox(height: 15),
            HSRecordsButton(),
          ],
        ),
      ),
    );
  }
}
