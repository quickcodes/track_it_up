import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:track_it_up/features/tracking/domain/entities/device_info.dart';

class DevicePathMapFlutterMap extends StatelessWidget {
  final List<DeviceInfo> deviceInfoList;
  // final DateTime dateToShowData;

  const DevicePathMapFlutterMap({
    super.key,
    required this.deviceInfoList,
    // required this.dateToShowData,
  });

  @override
  Widget build(BuildContext context) {
    final sortedData = deviceInfoList;
    //getFilteredAndSortedData();
    final points =
        sortedData.map((e) => LatLng(e.latitude, e.longitude)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Device Path Map')),
      body: points.isEmpty
          ? const Center(child: Text('No data to show on map.'))
          : FlutterMap(
              options: MapOptions(
                initialCenter: points.first,
                minZoom: 5,
                maxZoom: 50,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                // // PolyLines
                // PolylineLayer(
                //   polylines: [
                //     Polyline(
                //       points: points,
                //       color: Colors.blue,
                //       strokeWidth: 4,
                //     ),
                //   ],
                // ),
                MarkerLayer(
                  markers: [
                    // Interactive markers
                    for (var i = 0; i < points.length; i++)
                      Marker(
                        point: points[i],
                        width: 10,
                        height: 10,
                        child: GestureDetector(
                          onTap: () =>
                              _showDeviceInfoDialog(context, sortedData[i]),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blue, width: 2),
                            ),
                          ),
                        ),
                      ),

                    // // Start & End markers
                    // Marker(
                    //   point: points.first,
                    //   width: 40,
                    //   height: 40,
                    //   child:
                    //       const Icon(Icons.location_pin, color: Colors.green),
                    // ),
                    // if (points.length > 1)
                    //   Marker(
                    //     point: points.last,
                    //     width: 40,
                    //     height: 40,
                    //     child: const Icon(Icons.flag, color: Colors.red),
                    //   ),
                  ],
                ),
              ],
            ),
    );
  }

  void _showDeviceInfoDialog(BuildContext context, DeviceInfo info) {
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
                    const Text('📅 Timestamp',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(DateFormat('yyyy-MM-dd hh:mm:ss a')
                        .format(info.timestamp)),
                    const SizedBox(height: 20),
                    const Text('📱 Device Info',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('🔧 Model: ${info.deviceModel}'),
                    Text('💻 OS Version: ${info.osVersion}'),
                    Text('📐 Screen: ${info.screenResolution}'),
                    Text('📡 Network: ${info.networkInformation}'),
                    const SizedBox(height: 20),
                    const Text('📍 Location',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('🌐 Latitude: ${info.latitude}'),
                    Text('🌐 Longitude: ${info.longitude}'),
                    Text('🎯 Accuracy: ${info.accuracy} m'),
                    Text('⛰️ Altitude: ${info.altitude} m'),
                    Text('🏃 Speed: ${info.speed} m/s'),
                    Text('🧭 Heading: ${info.heading}°'),
                    const SizedBox(height: 20),
                    const Text('🔋 Battery',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                        'Status: ${info.batteryStatus.toString()}'),
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
