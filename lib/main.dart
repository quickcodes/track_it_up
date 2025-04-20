import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:objectbox/objectbox.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/models/device_info_model.dart';
import 'features/screens/device_summary_screen.dart';
import 'features/screens/home_screen.dart';
import 'features/services/device_info_service.dart';
import 'features/services/local_db_service.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Provides access to the ObjectBox Store throughout the app.
// ObjectBox? objectbox;
final Completer<Store> _storeCompleter = Completer<Store>();

Future<void> initStore() async {
  if (!_storeCompleter.isCompleted) {
    final store = await ObjectBox.create();
    _storeCompleter.complete(store.store);
  }
}

Future<Store> getStore() async {
  if (!_storeCompleter.isCompleted) {
    await initStore(); // Lazy init
  }
  return _storeCompleter.future;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DeviceAndLocationService().handlePermissions();
  // objectbox = await ObjectBox.create();

  // initialize store
  await initStore();
  await initializeService();
  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'TRACK IT UP SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
      foregroundServiceTypes: [AndroidForegroundType.location],
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  // DeviceAndLocationService infoService = DeviceAndLocationService();
  // final objectBoxInstance = objectbox.store.box<DeviceInfoModel>();
  // DeviceInfoModel? info;
  // try {
  //   info = await infoService.collectDeviceAndLocationInfo();
  //   objectBoxInstance.put(info);
  //   // log(objectBoxInstance
  //   //     .getAll()
  //   //     .map((deviceInfo) => deviceInfo.toString())
  //   //     .toList()
  //   //     .toString());
  //   print(info.toString());
  // } catch (e) {
  //   print('Error: $e');
  // }
  // await Future.delayed(Duration(seconds: 5));

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  // SharedPreferences preferences = await SharedPreferences.getInstance();
  // await preferences.setString("hello", "world");

  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // bring to foreground
  Timer.periodic(const Duration(seconds: 30), (timer) async {
    DeviceInfoModel? info;
    String address = '';
    try {
      // objectbox ??= await ObjectBox.create();

      DeviceAndLocationService infoService = DeviceAndLocationService();
      final store = await getStore();
      info = await infoService.collectDeviceAndLocationInfo();
      store.box<DeviceInfoModel>().put(info);
      print("=====>>>>> ### *** Device Info *** ### ${info.toString()}");
      final todaysInfo = store.box<DeviceInfoModel>().getAll();
      print("=====>>>>> ### *** Todays Info *** ### ${todaysInfo.length}");

      // List<Placemark> placemarks = [];
      // try {
      //   placemarks =
      //       await placemarkFromCoordinates(info.latitude, info.longitude);
      // } catch (e) {
      //   print("=====>>>>> ### *** Address *** ### ERROR: ${e}");
      // }

      // address = placemarks.isNotEmpty ? placemarks.first.toString() : '';
    } catch (e) {
      print("=====>>>>> ### *** Device Info *** ### ERROR: ${e}");
    }

    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        /// OPTIONAL for use custom notification
        /// the notification id must be equals with AndroidConfiguration when you call configure() method.
        flutterLocalNotificationsPlugin.show(
          888,
          'COOL SERVICE',
          'Awesome ${DateTime.now()}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'my_foreground',
              'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );

        // if you don't using custom notification, uncomment this
        // service.setForegroundNotificationInfo(
        //   title: "📍 ${info?.deviceModel} (🔋${info?.batteryStatus.target?.level})",
        //   content:
        //       "📡 ${info?.networkInformation}",
        // );

        final isCharging = info?.batteryStatus.target?.charging == true;
        final batteryLevel = info?.batteryStatus.target?.level ?? 'N/A';
        final chargingEmoji = isCharging ? '⚡' : '🔋';
        final currentTime =
            DateFormat('HH:mm:ss').format(info?.timestamp ?? DateTime.now());
        final speed = info?.speed?.toStringAsFixed(1) ?? '0.0';

        service.setForegroundNotificationInfo(
          title: "📍 ${info?.deviceModel} (${batteryLevel}) $chargingEmoji",
          content:
              "${getConnectionTypeEmojie(info?.networkInformation ?? '')}${info?.networkInformation} | 🚀 ${speed} m/s | 🕒 $currentTime",
        );
      }
    }

    /// you can see this log in logcat
    debugPrint('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

    // test using external plugin
    // final deviceInfo = DeviceInfoPlugin();
    // String? device;
    // if (Platform.isAndroid) {
    //   final androidInfo = await deviceInfo.androidInfo;
    //   device = androidInfo.model;
    // } else if (Platform.isIOS) {
    //   final iosInfo = await deviceInfo.iosInfo;
    //   device = iosInfo.model;
    // }
    // try {
    //   // objectbox ??= await ObjectBox.create();
    //   final store = await getStore();
    //   // print(
    //   //     "=====>>>>> ### *** Device Info *** ### ${await DeviceAndLocationService().collectDeviceAndLocationInfo()}");
    //   final todaysInfo = store.box<DeviceInfoModel>().getAll();
    //   print("=====>>>>> ### *** Todays Info *** ### ${todaysInfo.length}");
    // } catch (e) {
    //   print("=====>>>>> ### *** Todays Info *** ### ERROR: ${e}");
    // }
    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": info.toString(),
      },
    );
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[100],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

            // ElevatedButton(
            //   child: const Text("Foreground Mode"),
            //   onPressed: () =>
            //       FlutterBackgroundService().invoke("setAsForeground"),
            // ),
            // ElevatedButton(
            //   child: const Text("Background Mode"),
            //   onPressed: () =>
            //       FlutterBackgroundService().invoke("setAsBackground"),
            // ),
            // ElevatedButton(
            //   child: Text(text),
            //   onPressed: () async {
            //     final service = FlutterBackgroundService();
            //     var isRunning = await service.isRunning();
            //     isRunning
            //         ? service.invoke("stopService")
            //         : service.startService();

            //     setState(() {
            //       text = isRunning ? 'Start Service' : 'Stop Service';
            //     });
            //   },
            // ),