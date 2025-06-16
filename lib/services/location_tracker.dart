import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

StreamSubscription<Position>? locationSubscription;

Future<void> startLiveLocationUpdates(String nickname) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final dbRef = FirebaseDatabase.instance.ref('driver_locations/${user.uid}');

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
    return;
  }

  locationSubscription?.cancel(); // Ensure no duplicates

  locationSubscription = Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1,
    ),
  ).listen((Position pos) async {
    print('📍 Updating location: ${pos.latitude}, ${pos.longitude}');

  await dbRef.update({
    'latitude': pos.latitude,
    'longitude': pos.longitude,
    'timestamp': DateTime.now().toIso8601String(),
    'nickname': nickname,
    'uid': user.uid,
  });
});

}
