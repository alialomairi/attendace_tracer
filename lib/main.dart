import 'package:flutter_background/flutter_background.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';
import 'package:background_location/background_location.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final androidConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: "flutter_background example app",
    notificationText: "Background notification for keeping the example app running in the background",
    notificationImportance: AndroidNotificationImportance.Default
  );
  await FlutterBackground.initialize(androidConfig: androidConfig);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String latitude = 'waiting...';
  String longitude = 'waiting...';
  String altitude = 'waiting...';
  String accuracy = 'waiting...';
  String bearing = 'waiting...';
  String speed = 'waiting...';
  String time = 'waiting...';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Background Location Service'),
        ),
        body: Center(
          child: ListView(
            children: <Widget>[
              locationData('Latitude: ' + latitude),
              locationData('Longitude: ' + longitude),
              locationData('Altitude: ' + altitude),
              locationData('Accuracy: ' + accuracy),
              locationData('Bearing: ' + bearing),
              locationData('Speed: ' + speed),
              locationData('Time: ' + time),
              ElevatedButton(
                  onPressed: () async {
                    var status = await Permission.notification.request();
                    if (status.isDenied) {
                      // We didn't ask for permission yet or the permission has been denied before, but not permanently.
                      await BackgroundLocation.setAndroidNotification(
                        title: 'Background service is running',
                        message: 'Background location in progress',
                        icon: '@mipmap/ic_launcher',
                      );
                    }

// You can can also directly ask the permission about its status.
                    else {
                      // The OS restricts access, for example because of parental controls.
                    }
                    //await BackgroundLocation.setAndroidConfiguration(1000);
                    await FlutterBackground.enableBackgroundExecution();
                    await BackgroundLocation.startLocationService(
                        distanceFilter: 0);
                    BackgroundLocation.getLocationUpdates((location) {
                      setState(() {
                        latitude = location.latitude.toString();
                        longitude = location.longitude.toString();
                        accuracy = location.accuracy.toString();
                        altitude = location.altitude.toString();
                        bearing = location.bearing.toString();
                        speed = location.speed.toString();
                        time = DateTime.fromMillisecondsSinceEpoch(
                            location.time!.toInt())
                            .toString();
                      });
                      DatabaseReference ref = FirebaseDatabase.instance.ref();
                      String? key = ref.child("Locations").push().key;
                      ref.child("Locations/l1").set(
                          <String, dynamic>{
                            'latitude' : location.latitude.toString(),
                            'longitude' : location.longitude.toString(),
                            'accuracy' : location.accuracy.toString(),
                            'altitude' : location.altitude.toString(),
                            'bearing' : location.bearing.toString(),
                            'speed' : location.speed.toString(),
                            'time' : DateTime.fromMillisecondsSinceEpoch(
                                location.time!.toInt())
                                .toString(),

                          }
                      );

                      // print('''\n
                      //   Latitude:  $latitude
                      //   Longitude: $longitude
                      //   Altitude: $altitude
                      //   Accuracy: $accuracy
                      //   Bearing:  $bearing
                      //   Speed: $speed
                      //   Time: $time
                      // ''');
                    });
                  },
                  child: Text('Start Location Service')),
              ElevatedButton(
                  onPressed: () {
                    BackgroundLocation.stopLocationService();
                  },
                  child: Text('Stop Location Service')),
              ElevatedButton(
                  onPressed: () {
                    getCurrentLocation();
                  },
                  child: Text('Get Current Location')),
            ],
          ),
        ),
      ),
    );
  }

  Widget locationData(String data) {
    return Text(
      data,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      textAlign: TextAlign.center,
    );
  }

  void getCurrentLocation() {
    BackgroundLocation().getCurrentLocation().then((location) {
      DatabaseReference ref = FirebaseDatabase.instance.ref();
      String? key = ref.child("Locations").push().key;
      ref.child("Locations/$key").set(
        <String, dynamic>{
      'latitude' : location.latitude.toString(),
      'longitude' : location.longitude.toString(),
      'accuracy' : location.accuracy.toString(),
      'altitude' : location.altitude.toString(),
      'bearing' : location.bearing.toString(),
      'speed' : location.speed.toString(),
      'time' : DateTime.fromMillisecondsSinceEpoch(
      location.time!.toInt())
          .toString(),

      }
      );

      setState(() {
        latitude = location.latitude.toString();
        longitude = location.longitude.toString();
        accuracy = location.accuracy.toString();
        altitude = location.altitude.toString();
        bearing = location.bearing.toString();
        speed = location.speed.toString();
        time = DateTime.fromMillisecondsSinceEpoch(
            location.time!.toInt())
            .toString();
      });

      //print('This is current Location ' + location.toMap().toString());
    });
  }

  // @override
  // void dispose() {
  //   //BackgroundLocation.stopLocationService();
  //   super.dispose();
  // }
}