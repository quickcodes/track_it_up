import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:intl/intl.dart';
import 'package:track_it_up/main.dart';
import 'package:track_it_up/objectbox.g.dart';

import '../models/device_info_model.dart';
import 'data_entry_view.dart';
import 'device_summary_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String text = "Stop Service";
  bool isLoading = false;

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
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔄 Live Data from StreamBuilder
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: StreamBuilder<Map<String, dynamic>?>(
                  stream: FlutterBackgroundService().on('update'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingState();
                    }

                    if (!snapshot.hasData || snapshot.data == null) {
                      return _buildNoDataState();
                    }

                    final data = snapshot.data!;
                    final deviceData = data["device"] ?? "—";
                    final timestamp = DateTime.tryParse(data["current_date"]);
                    final formattedTime = timestamp != null
                        ? DateFormat.yMMMEd().add_jm().format(timestamp)
                        : "—";

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📡 Live Device Data',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          formattedTime,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          deviceData,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 15),

            // 📅 View Coordinates by Date Button
            ElevatedButton.icon(
              icon: isLoading
                  ? const SizedBox(
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.calendar_today),
              label: const Text("View Coordinates by Date"),
              onPressed: () async {
                if (isLoading) return;
                final DateTime? selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );

                if (selectedDate != null) {
                  setState(() {
                    isLoading = true;
                  });
                  try {
                    // final store = await getStore();
                    // final objectBoxInstance = store.box<DeviceInfoModel>();
                    // final dataList = await objectBoxInstance.getAllAsync();

                    // final filteredData =
                    //     getFilteredAndSortedData(dataList, selectedDate);

                    final store = await getStore();
                    final objectBoxInstance = store.box<DeviceInfoModel>();

                    final startOfDay = DateTime(selectedDate.year,
                        selectedDate.month, selectedDate.day);
                    final endOfDay = DateTime(selectedDate.year,
                        selectedDate.month, selectedDate.day, 23, 59, 59, 999);

                    final query = objectBoxInstance
                        .query(DeviceInfoModel_.timestamp.between(
                            startOfDay.millisecondsSinceEpoch,
                            endOfDay.millisecondsSinceEpoch))
                        .build();

                    final filteredData = await query.findAsync();
                    query.close();

                    filteredData.sort((a, b) => a.timestamp.compareTo(
                        b.timestamp)); // Optional: if not already sorted

                    if (filteredData.isEmpty) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text("No data available for selected date."),
                            backgroundColor: Colors.orangeAccent,
                          ),
                        );
                      }
                      return;
                    }
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeviceSummaryScreen(
                            deviceInfoList: filteredData,
                            selectedDate: selectedDate,
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (kDebugMode) {
                      print("Error: $e");
                    }
                  } finally {
                    setState(() {
                      isLoading = false;
                    });
                  }
                }
              },
            ),

            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(Icons.date_range),
              label: const Text("View Records"),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DateEntryWrapView(),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Filter and sort data by date
  List<DeviceInfoModel> getFilteredAndSortedData(
      List<DeviceInfoModel> deviceInfoList, DateTime selectedDate) {
    final filtered = deviceInfoList
        .where((e) =>
            e.timestamp.year == selectedDate.year &&
            e.timestamp.month == selectedDate.month &&
            e.timestamp.day == selectedDate.day)
        .toList();

    filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return filtered;
  }

  Widget _buildLoadingState() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 20),
        Text(
          "Waiting for live data...",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildNoDataState() {
    return const Column(
      children: [
        Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
        SizedBox(height: 12),
        Text(
          "No data received.",
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }

  // 🔹 Optional: Get device info stream
  Future<Stream<List<DeviceInfoModel>>> getTasksStream() async {
    final store = await getStore();
    final query =
        store.box<DeviceInfoModel>().query().watch(triggerImmediately: true);

    return query!.map((query) => query.find());
  }
}
