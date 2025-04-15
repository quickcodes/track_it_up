import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../models/device_info_model.dart';
import '../models/device_summary_model.dart';

class DevicePathMapFlutterMap extends StatelessWidget {
  final List<DeviceInfoModel> deviceInfoList;
  final DateTime dateToShowData;

  const DevicePathMapFlutterMap(
      {super.key, required this.deviceInfoList, required this.dateToShowData});

  List<LatLng> getSortedLatLngPoints(List<DeviceInfoModel> dataList) {
    // final now = DateTime.now();

    // Filter for today's data only
    final todayData = dataList.where((e) {
      return e.timestamp.year == dateToShowData.year &&
          e.timestamp.month == dateToShowData.month &&
          e.timestamp.day == dateToShowData.day;
    }).toList();

    // Log timestamps for debugging
    // log("Today's Coordinates: ${todayData.map((e) => DateFormat('hh:mm:ss a').format(e.timestamp)).join(", ")}");

    // Sort by timestamp
    todayData.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Map to LatLng
    return todayData.map((e) => LatLng(e.latitude, e.longitude)).toList();
  }

  // Future<String> fetchFrequentlyVisitedAddress(LatLng position) async {
  //   List<Placemark> placemarks =
  //       await placemarkFromCoordinates(position.latitude, position.longitude);
  //   Placemark place = placemarks.first;
  //   log("=====>>>>> Most Visited Address ${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}");
  //   return "${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}";
  // }

  @override
  Widget build(BuildContext context) {
    final points = getSortedLatLngPoints(deviceInfoList);
    final summary = summarizeDeviceInfoData(deviceInfoList);
    // fetchFrequentlyVisitedAddress(LatLng(summary.mostVisitedLocation!.latitude,
    //     summary.mostVisitedLocation!.longitude));

    return Scaffold(
      appBar: AppBar(title: const Text('Device Path')),
      body: Column(
        children: [
          // 📊 Summary section
          Card(
            margin: const EdgeInsets.all(12),
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📊 Daily Summary',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      Text('📅 Date: ${summary.date}'),
                      Text('🧾 Records: ${summary.totalRecords}'),
                      Text(
                          '🕒 Start: ${DateFormat('hh:mm a').format(summary.startTime)}'),
                      Text(
                          '🏁 End: ${DateFormat('hh:mm a').format(summary.endTime)}'),
                      Text(
                          '⏱️ Duration: ${summary.activeDuration.inHours}h ${summary.activeDuration.inMinutes % 60}m'),
                      Text(
                          '🚶 Distance: ${summary.totalDistanceKm.toStringAsFixed(2)} km'),
                      if (summary.mostVisitedLocation != null)
                        Text(
                            '📍 Frequent Spot: ${summary.mostVisitedLocation!.latitude.toStringAsFixed(4)}, ${summary.mostVisitedLocation!.longitude.toStringAsFixed(4)}'),
                      if (summary.longestStopDuration != null)
                        Text(
                            '🛑 Longest Stop: ${summary.longestStopDuration!.inMinutes} min'),
                      if (summary.minBatteryLevel != null)
                        Text('🔋 Min Battery: ${summary.minBatteryLevel}'),
                      Text('🔌 Charging: ${summary.chargingSessions}x'),
                      Text('📶 Network Changes: ${summary.networkChanges}'),
                      Text(
                          '🔵 Bluetooth: ${summary.uniqueBluetoothDevices} devices'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Flexible(
            child: FlutterMap(
              options: MapOptions(
                initialCenter:
                    points.isNotEmpty ? points.first : const LatLng(0, 0),
                minZoom: 5,
                maxZoom: 50,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                if (points.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: points,
                        color: Colors.blue,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    // Interactive markers for all points
                    for (var i = 0; i < points.length; i++)
                      Marker(
                        point: points[i],
                        width: 10,
                        height: 10,
                        child: GestureDetector(
                          onTap: () =>
                              _showDeviceInfoDialog(context, deviceInfoList[i]),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blue, width: 2),
                            ),
                          ),
                        ),
                      ),

                    // Start and end icons
                    if (points.isNotEmpty)
                      Marker(
                        point: points.first,
                        width: 40,
                        height: 40,
                        child:
                            const Icon(Icons.location_pin, color: Colors.green),
                      ),
                    if (points.length > 1)
                      Marker(
                        point: points.last,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.flag, color: Colors.red),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeviceInfoDialog(BuildContext context, DeviceInfoModel info) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const Text(
                      '📅 Timestamp',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(DateFormat('yyyy-MM-dd hh:mm:ss a')
                        .format(info.timestamp)),
                    const SizedBox(height: 20),
                    const Text(
                      '📱 Device Info',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text('🔧 Model: ${info.deviceModel}'),
                    Text('💻 OS Version: ${info.osVersion}'),
                    Text('📐 Screen: ${info.screenResolution}'),
                    Text('📡 Network: ${info.networkInformation}'),
                    const SizedBox(height: 20),
                    const Text(
                      '📍 Location',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text('🌐 Latitude: ${info.latitude}'),
                    Text('🌐 Longitude: ${info.longitude}'),
                    Text('🎯 Accuracy: ${info.accuracy} m'),
                    Text('⛰️ Altitude: ${info.altitude} m'),
                    Text('🏃 Speed: ${info.speed} m/s'),
                    Text('🧭 Heading: ${info.heading}°'),
                    const SizedBox(height: 20),
                    const Text(
                      '🔋 Battery',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                        'Status: ${info.batteryStatus.target?.toString() ?? 'N/A'}'),
                    const SizedBox(height: 20),
                    // const Text(
                    //   '🧲 Nearby Bluetooth Devices',
                    //   style:
                    //       TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    // ),
                    // ...info.nearbyBluetoothDevices
                    //     .map((device) => Text('• $device')),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
