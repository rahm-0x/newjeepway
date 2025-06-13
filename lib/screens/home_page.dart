import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../utils/constants.dart';
import '../widgets/map_widget.dart';
import '../widgets/dropdown_city.dart';
import '../services/ors_service.dart';

class JeepwayHomePage extends StatefulWidget {
  const JeepwayHomePage({super.key});

  @override
  _JeepwayHomePageState createState() => _JeepwayHomePageState();
}

class _JeepwayHomePageState extends State<JeepwayHomePage> {
  String _selectedCity = 'Milano';
  final MapController _mapController = MapController();
  final PopupController _popupController = PopupController();

  // ✅ ORS service now uses the key from environment variables
  late final OrsService _orsService;

  @override
  void initState() {
    super.initState();
    _orsService = OrsService(); // ✅ No param
  }
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jeepway'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Text(
                user != null ? 'Welcome, ${user.email}' : 'Please Login/Register',
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            if (user == null)
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('Login/Register'),
                onTap: () async {
                  final result = await Navigator.pushNamed(context, '/login');
                  if (result == true) {
                    setState(() {}); // Refresh drawer
                  }
                },
              ),
            if (user != null)
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  setState(() {});
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CityDropdown(
              selectedCity: _selectedCity,
              onCityChanged: (newCity) {
                setState(() {
                  _selectedCity = newCity!;
                  _mapController.move(cityCoordinates[_selectedCity]!, 13.0);
                });
              },
            ),
          ),
          Expanded(
            child: MapWidget(
              mapController: _mapController,
              popupController: _popupController,
              selectedCity: _selectedCity,
              orsService: _orsService,
            ),
          ),
        ],
      ),
    );
  }
}
