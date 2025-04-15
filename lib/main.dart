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
import 'features/screens/map_screen.dart';
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
          title: "📍 ${info?.deviceModel} (${batteryLevel}%) $chargingEmoji",
          content:
              "${info?.networkInformation} | 🚀 ${speed} m/s | 🕒 $currentTime",
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
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String text = "Stop Service";
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Service App'),
        ),
        body: Column(
          children: [
            StreamBuilder<Map<String, dynamic>?>(
              stream: FlutterBackgroundService().on('update'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data = snapshot.data!;
                String? device = data["device"];
                DateTime? date = DateTime.tryParse(data["current_date"]);
                return Text(device ?? 'Unknown');
                // Column(
                //   children: [
                //     Text(device ?? 'Unknown'),
                //     Text(date.toString()),
                //   ],
                // );
              },
            ),
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

            // ElevatedButton(
            //   child: const Text("View Today's Co'ordinates"),
            //   onPressed: () async {
            //     final store = await getStore();
            //     // DeviceAndLocationService infoService =
            //     //     DeviceAndLocationService();
            //     final objectBoxInstance = store.box<DeviceInfoModel>();

            //     // try {
            //     //   DeviceInfoModel info =
            //     //       await infoService.collectDeviceAndLocationInfo();
            //     //   objectBoxInstance?.put(info);
            //     //   log(objectBoxInstance!
            //     //       .getAll()
            //     //       .map((deviceInfo) => deviceInfo.toString())
            //     //       .toList()
            //     //       .toString());
            //     //   // log(info.toString());
            //     // } catch (e) {
            //     //   print('Error: $e');
            //     // }

            //     Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => DevicePathMapFlutterMap(
            //             deviceInfoList: objectBoxInstance.getAll(),
            //             dateToShowData: DateTime.now(),
            //           ),
            //         ));
            //   },
            // ),
            ElevatedButton(
              child: const Text("View Coordinates by Date"),
              onPressed: () async {
                // Show the DatePicker
                final DateTime? selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020), // Customize as needed
                  lastDate: DateTime.now(),
                );

                // If user selected a date, proceed
                if (selectedDate != null) {
                  final store = await getStore();
                  final objectBoxInstance = store.box<DeviceInfoModel>();

                  // Navigate to the map screen with the selected date
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DevicePathMapFlutterMap(
                        deviceInfoList: objectBoxInstance.getAll(),
                        dateToShowData: selectedDate,
                      ),
                    ),
                  );
                }
              },
            ),

            // const LogView(),
            // Expanded(
            //   child: StreamBuilder<List<DeviceInfoModel>>(
            //     stream: getTasksStream(),
            //     builder: (context, snapshot) {
            //       if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            //         return ListView.builder(
            //           itemCount: snapshot.data!.length,
            //           itemBuilder: (context, index) {
            //             final deviceInfo = snapshot.data![index];
            //             final formattedTime = DateFormat('dd MMM yyyy, hh:mm a')
            //                 .format(deviceInfo.timestamp);

            //             return Card(
            //               margin: const EdgeInsets.symmetric(
            //                   horizontal: 12, vertical: 8),
            //               elevation: 3,
            //               child: ExpansionTile(
            //                 title: Text(
            //                   "Device: ${deviceInfo.deviceModel}",
            //                   style: Theme.of(context).textTheme.titleMedium,
            //                 ),
            //                 subtitle: Column(
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: [
            //                     Text(
            //                         "Battery: ${deviceInfo.batteryStatus.target?.toString() ?? 'N/A'}"),
            //                     Text(
            //                         "Location: ${deviceInfo.latitude}, ${deviceInfo.longitude}"),
            //                     Text("Time: $formattedTime"),
            //                   ],
            //                 ),
            //                 children: [
            //                   Padding(
            //                     padding: const EdgeInsets.symmetric(
            //                         horizontal: 16.0, vertical: 8),
            //                     child: Column(
            //                       crossAxisAlignment: CrossAxisAlignment.start,
            //                       children: [
            //                         sectionTitle(context, "Device Info"),
            //                         infoText("Model", deviceInfo.deviceModel),
            //                         infoText(
            //                             "OS Version", deviceInfo.osVersion),
            //                         infoText("Resolution",
            //                             deviceInfo.screenResolution),
            //                         infoText(
            //                             "Unique ID", deviceInfo.deviceUniqueID),
            //                         const SizedBox(height: 10),
            //                         sectionTitle(context, "Battery Status"),
            //                         infoText(
            //                             "Battery",
            //                             deviceInfo.batteryStatus.target
            //                                     ?.toString() ??
            //                                 'N/A'),
            //                         const SizedBox(height: 10),
            //                         sectionTitle(context, "Network Info"),
            //                         infoText("Network",
            //                             deviceInfo.networkInformation),
            //                         const SizedBox(height: 10),
            //                         sectionTitle(context, "Location Info"),
            //                         infoText("Latitude",
            //                             deviceInfo.latitude.toString()),
            //                         infoText("Longitude",
            //                             deviceInfo.longitude.toString()),
            //                         infoText("Accuracy",
            //                             deviceInfo.accuracy.toString()),
            //                         infoText("Altitude",
            //                             deviceInfo.altitude.toString()),
            //                         infoText("Heading",
            //                             deviceInfo.heading.toString()),
            //                         infoText(
            //                             "Speed", deviceInfo.speed.toString()),
            //                         infoText("Speed Accuracy",
            //                             deviceInfo.speedAccuracy.toString()),
            //                         infoText("Timestamp",
            //                             deviceInfo.timestamp.toString()),
            //                         const SizedBox(height: 10),
            //                         sectionTitle(
            //                             context, "Nearby Bluetooth Devices"),
            //                         ...deviceInfo.nearbyBluetoothDevices.map(
            //                             (bt) => Text("• $bt",
            //                                 style: TextStyle(
            //                                     color: Colors.grey[700]))),
            //                       ],
            //                     ),
            //                   )
            //                 ],
            //               ),
            //             );
            //           },
            //         );
            //       } else {
            //         return const Center(child: Text("No Data Found"));
            //       }
            //     },
            //   ),
            // )

            // const Expanded(
            //   child: LogView(),
            // ),
          ],
        ),
      ),
    );
  }

  Future<Stream<List<DeviceInfoModel>>> getTasksStream() async {
    // final taskBox = objectbox.store.box();
    final store = await getStore();
    final query = store
        .box<DeviceInfoModel>()
        .query()
        // .order(DeviceInfoModel.timestamp, flags: Order.descending)
        .watch(triggerImmediately: true);

    return query!.map((query) => query.find());
  }

  Widget sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleSmall
          ?.copyWith(fontWeight: FontWeight.bold, color: Colors.blueGrey),
    );
  }

  Widget infoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        "$label: $value",
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}

class LogView extends StatefulWidget {
  const LogView({Key? key}) : super(key: key);

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  late final Timer timer;
  List<String> logs = [];

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      await sp.reload();
      logs = sp.getStringList('log') ?? [];
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(logs.map((e) => e.toString()).toList().toString());
    // return ListView.builder(
    //   itemCount: logs.length,
    //   itemBuilder: (context, index) {
    //     final log = logs.elementAt(index);
    //     return Text(log);
    //   },
    // );
  }
}
