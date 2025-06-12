import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrsService {
  final String _apiKey;

  OrsService(this._apiKey);

  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final url = Uri.parse('https://api.openrouteservice.org/v2/directions/driving-car/geojson');
    final body = jsonEncode({
      "coordinates": [
        [start.longitude, start.latitude],
        [end.longitude, end.latitude]
      ]
    });

    final response = await http.post(
      url,
      headers: {
        'Authorization': _apiKey,
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch route: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final coords = data['features'][0]['geometry']['coordinates'];

    return coords.map<LatLng>((coord) => LatLng(coord[1], coord[0])).toList();
  }
}
