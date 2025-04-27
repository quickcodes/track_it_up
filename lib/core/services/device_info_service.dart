import 'dart:io';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:track_it_up/features/tracking/data/models/battery_status_model.dart';

import '../../features/tracking/data/models/device_info_model.dart';

class DeviceAndLocationService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Battery _battery = Battery();
  final Connectivity _connectivity = Connectivity();

  Future<DeviceInfoModel> collectDeviceAndLocationInfo() async {
    // handlePermissions();
    String deviceModel = '';
    String osVersion = '';
    String deviceUniqueID = '';
    String screenResolution = '';
    BatteryStatusModel batteryStatus;
    String networkInfo = '';
    List<String> nearbyBluetoothDevices = [];

    // Get Device Info
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        deviceModel = androidInfo.model;
        osVersion = 'Android ${androidInfo.version.release}';
        deviceUniqueID = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        deviceModel = iosInfo.utsname.machine;
        osVersion = 'iOS ${iosInfo.systemVersion}';
        deviceUniqueID = iosInfo.identifierForVendor ?? 'Unknown';
      }

      final window = WidgetsBinding.instance.platformDispatcher.views.first;
      final screenSize = window.physicalSize / window.devicePixelRatio;
      screenResolution =
          '${screenSize.width.toInt()}x${screenSize.height.toInt()}';

      // Battery
      int batteryLevel = await _battery.batteryLevel;
      BatteryState batteryState = await _battery.batteryState;
      batteryStatus = BatteryStatusModel(
        level: '$batteryLevel%',
        charging: batteryState == BatteryState.charging,
        status: batteryState.toString().split('.').last,
      );

      // Network
      List<ConnectivityResult> result = await _connectivity.checkConnectivity();
      networkInfo = _getConnectionType(
          result.isNotEmpty ? result.first : ConnectivityResult.none);

      // Permissions

      // Location
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        ),
      );

      // Bluetooth
      // FlutterBluePlus.startScan(timeout: const Duration(seconds: 4))
      //     .catchError((error) {
      //   print("Error starting scan: $error");
      // });

      // // Listen to the scanning results
      // FlutterBluePlus.onScanResults.listen((results) {
      //   for (var result in results) {
      //     print(
      //         'Found Bluetooth device! Name: ${result.device.advName}, RSSI: ${result.rssi}');
      //     nearbyBluetoothDevices.add("${result.toString()}");
      //   }
      // });

      // // Optional: Stop scanning as needed
      // await Future.delayed(const Duration(seconds: 4));
      // FlutterBluePlus.stopScan();
      final deviceInfo = DeviceInfoModel(
        deviceModel: deviceModel,
        osVersion: osVersion,
        screenResolution: screenResolution,
        deviceUniqueID: deviceUniqueID,
        // batteryStatus: batteryStatus,
        networkInformation: networkInfo,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        heading: position.heading,
        speed: position.speed,
        speedAccuracy: position.speedAccuracy,
        timestamp: DateTime.now(), //position.timestamp,
        nearbyBluetoothDevices: nearbyBluetoothDevices,
      );

      deviceInfo.batteryStatus.target = batteryStatus;
      return deviceInfo;
    } on PlatformException catch (e) {
      throw Exception('Failed to get info: ${e.message}');
    }
  }

  Future<void> handlePermissions() async {
    // handlePermissions();
    // Location
    LocationPermission locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied ||
        locationPermission == LocationPermission.deniedForever) {
      locationPermission = await Geolocator.requestPermission();
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      // throw Exception('Location services are disabled.');
      await Geolocator.openLocationSettings();
      return; // Exit the function to prevent further execution
    }

    // Bluetooth
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.locationWhenInUse.request();

    await Permission.notification.request();
  }

  String _getConnectionType(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return 'Wi-Fi';
      case ConnectivityResult.mobile:
        return 'Cellular';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.none:
        return 'No Connection';
      default:
        return 'Unknown';
    }
  }
}

String getConnectionTypeEmojie(String result) {
  switch (result) {
    case 'Wi-Fi':
      return '📶';
    case 'Cellular':
      return '📱';
    case 'Ethernet':
      return '🔌';
    case 'Bluetooth':
      return '🟦';
    case 'No Internet':
      return '❌';
    default:
      return '❓';
  }
}
