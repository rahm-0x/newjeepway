import 'package:latlong2/latlong.dart';

// One clear route from Milano outward
final List<List<LatLng>> jeepneyRoutes = [
  [
    LatLng(15.906102, 120.808494), // Start: Milano
    LatLng(15.908500, 120.810800),
    LatLng(15.911000, 120.813200),
    LatLng(15.914500, 120.816500),
    LatLng(15.918000, 120.819800),
    LatLng(15.921000, 120.821900),
    LatLng(15.923595, 120.822558), // End: requested coordinate
  ]
];

// One mock jeep on the route
final List<Map<String, dynamic>> jeepneyDetails = [
  {'routeNumber': 'M1', 'seats': 18},
];

// City coordinates
final Map<String, LatLng> cityCoordinates = {
  'Manila': LatLng(14.5995, 120.9842),
  'Cebu': LatLng(10.3157, 123.8854),
  'Milano': LatLng(15.906102, 120.808494),
  'Davao': LatLng(7.1907, 125.4553),
  'Baguio': LatLng(16.4023, 120.5960),
};
