import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import '../utils/constants.dart';
import '../services/ors_service.dart';
import 'jeep_detail_sheet.dart';

class MapWidget extends StatefulWidget {
  final MapController mapController;
  final PopupController popupController;
  final String selectedCity;
  final OrsService orsService;

  const MapWidget({
    super.key,
    required this.mapController,
    required this.popupController,
    required this.selectedCity,
    required this.orsService,
  });

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  LatLng? userPosition;
  List<LatLng> mockJeepPositions = [];
  Timer? _mockMovementTimer;
  List<LatLng>? orsRoute;

  @override
  void initState() {
    super.initState();
    mockJeepPositions = jeepneyRoutes.map((route) => route.first).toList();
    _startMockMovement();
  }

  @override
  void dispose() {
    _mockMovementTimer?.cancel();
    super.dispose();
  }

  void _startMockMovement() {
    _mockMovementTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() {
        for (int i = 0; i < jeepneyRoutes.length; i++) {
          final current = mockJeepPositions[i];
          final route = jeepneyRoutes[i];
          final index = route.indexOf(current);
          final nextIndex = (index + 1) % route.length;
          mockJeepPositions[i] = route[nextIndex];
        }
      });
    });
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      userPosition = LatLng(position.latitude, position.longitude);
    });

    widget.mapController.move(userPosition!, 15.0);
  }

  void _toggleRouteDetails(int index, BuildContext context) async {
    final start = mockJeepPositions[index];
    final route = jeepneyRoutes[index];
    final end = route.last;

    if (orsRoute != null) {
      setState(() => orsRoute = null);
      Navigator.of(context).maybePop();
      return;
    }

    try {
      final fetchedRoute = await widget.orsService.getRoute(start, end);
      setState(() {
        orsRoute = fetchedRoute;
      });

      final details = jeepneyDetails.length > index ? jeepneyDetails[index] : {};
      showModalBottomSheet(
        context: context,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => JeepDetailSheet(
          driverName: 'Mock Driver ${index + 1}',
          routeNumber: details['routeNumber'] ?? '---',
          seats: details['seats'] ?? 0,
        ),
      );
    } catch (e) {
      debugPrint('Error fetching ORS route: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: widget.mapController,
          options: MapOptions(
            initialCenter: cityCoordinates[widget.selectedCity]!,
            maxZoom: 30.0,
            minZoom: 1.0,
            onTap: (_, __) {
              widget.popupController.hideAllPopups();
              setState(() => orsRoute = null);
              Navigator.of(context).maybePop();
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),

            if (orsRoute != null)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: orsRoute!,
                    strokeWidth: 4.0,
                    color: Colors.green,
                  )
                ],
              ),

            MarkerLayer(
              markers: mockJeepPositions.map((pos) {
                int index = mockJeepPositions.indexOf(pos);
                return Marker(
                  width: 40,
                  height: 40,
                  point: pos,
                  child: GestureDetector(
                    onTap: () => _toggleRouteDetails(index, context),
                    child: Image.asset(
                      'assets/jeepneyicon.png',
                      width: 40,
                      height: 40,
                    ),
                  ),
                );
              }).toList(),
            ),

            StreamBuilder<DatabaseEvent>(
              stream: FirebaseDatabase.instance.ref("driver_locations").onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                  return const MarkerLayer(markers: []);
                }

                final data = Map<String, dynamic>.from(
                  snapshot.data!.snapshot.value as Map,
                );

                final markers = data.entries.map((entry) {
                  final value = Map<String, dynamic>.from(entry.value);
                  final lat = value['latitude']?.toDouble();
                  final lng = value['longitude']?.toDouble();
                  final nickname = value['nickname'] ?? 'Driver';

                  if (lat == null || lng == null) return null;

                  return Marker(
                    width: 40,
                    height: 40,
                    point: LatLng(lat, lng),
                    child: Tooltip(
                      message: nickname,
                      child: Image.asset(
                        'assets/jeepneyicon.png',
                        width: 40,
                        height: 40,
                      ),
                    ),
                  );
                }).whereType<Marker>().toList();

                return MarkerLayer(markers: markers);
              },
            ),

            if (userPosition != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: userPosition!,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
          ],
        ),

        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            child: const Icon(Icons.my_location),
            onPressed: _getUserLocation,
          ),
        ),
      ],
    );
  }
}
