import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

class DriverRegistrationPage extends StatefulWidget {
  const DriverRegistrationPage({super.key});

  @override
  _DriverRegistrationPageState createState() => _DriverRegistrationPageState();
}

class _DriverRegistrationPageState extends State<DriverRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController routeController = TextEditingController();
  final TextEditingController seatSizeController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();

  bool isSubmitting = false;
  StreamSubscription<Position>? _locationSubscription;

  Future<void> _enableLocationAndSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Not logged in");

      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception("Location permission denied");
      }

      Position position = await Geolocator.getCurrentPosition();

      // Save static profile to Firestore
      await FirebaseFirestore.instance.collection('drivers').doc(user.uid).set({
        'name': nameController.text.trim(),
        'city': cityController.text.trim(),
        'route': routeController.text.trim(),
        'seatSize': seatSizeController.text.trim(),
        'nickname': nicknameController.text.trim(),
        'uid': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      final dbRef = FirebaseDatabase.instance.ref('driver_locations/${user.uid}');

      // Initial position write
      await dbRef.set({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'nickname': nicknameController.text.trim(),
        'uid': user.uid,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Start live updates using LocationSettings
      LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );

      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position pos) async {
        await dbRef.update({
          'latitude': pos.latitude,
          'longitude': pos.longitude,
          'timestamp': DateTime.now().toIso8601String(),
        });
      });

      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Required' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Registration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(nameController, "Name"),
              _buildTextField(cityController, "City"),
              _buildTextField(routeController, "Route"),
              _buildTextField(seatSizeController, "Seat Size"),
              _buildTextField(nicknameController, "Nickname"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isSubmitting ? null : _enableLocationAndSubmit,
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Enable Location & Submit'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
