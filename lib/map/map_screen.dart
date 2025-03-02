import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapbox_gl/mapbox_gl.dart'as mapbox;
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

import '../main.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _currentLocationController = TextEditingController();
  final TextEditingController _destinationLocationController = TextEditingController();
  late mapbox.MapboxMapController _mapController;
  final String _accessToken = 'sk.eyJ1IjoiaG16YWExMCIsImEiOiJjbHkwZ3ZjODgwbXh4MmhwODdhcTJsdTcyIn0.hv5gii8DjzDjj4Sacpqyew';

  @override
  void initState() {
    super.initState();
    _checkLocationServices();
  }

  void _onMapCreated(mapbox.MapboxMapController controller) {
    _mapController = controller;
  }

  Future<void> _checkLocationServices() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, prompt user to enable them
      bool serviceEnabled = await Geolocator.openLocationSettings();
      if (!serviceEnabled) {
        // User declined to enable location services
        _showLocationServicesDisabledDialog();
        return;
      }
    }

    // Check for location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        // Permissions are denied, show error message
        _showLocationPermissionsDeniedDialog();
        return;
      }
    }

    // Get the current location
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final coordinates = [position.longitude, position.latitude];
      final currentPlace = await _fetchPlaceName(coordinates);

      setState(() {
         _currentLocationController.value = _currentLocationController.value.copyWith(
        text: currentPlace,
        selection: TextSelection.collapsed(offset: 0),
        composing: TextRange.empty,
      );
      });
    } catch (error) {
      print("Error fetching current location: $error");
    }
  }

  Future<String> _fetchPlaceName(List<double> coordinates) async {
    final url = 'https://api.mapbox.com/geocoding/v5/mapbox.places/${coordinates[0]},${coordinates[1]}.json?access_token=$_accessToken';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final feature = json['features'][0];
      final placeName = feature['place_name'];
      return placeName;
    } else {
      throw Exception('Failed to load location');
    }
  }

  Future<List<double>> _fetchCoordinates(String place) async {
    final url = 'https://api.mapbox.com/geocoding/v5/mapbox.places/$place.json?access_token=$_accessToken';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final feature = json['features'][0];
      final double lat = feature['center'][1];
      final double lon = feature['center'][0];
      return [lon, lat];
    } else {
      throw Exception('Failed to load location');
    }
  }

  Future<Map<String, dynamic>> _fetchRoute(double startLat, double startLon, double endLat, double endLon) async {
    final url = 'https://api.mapbox.com/directions/v5/mapbox/driving/$startLon,$startLat;$endLon,$endLat?geometries=geojson&access_token=$_accessToken';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final route = json['routes'][0];
      final distance = route['distance']; // Distance in meters
      final geometry = route['geometry'];

      return {
        'distance': distance,
        'geometry': geometry,
      };
    } else {
      throw Exception('Failed to fetch route data.');
    }
  }

  void _drawRoute(Map<String, dynamic> geometry) {
    final coordinates = geometry['coordinates'];
    final List<mapbox.LatLng> route = coordinates.map<mapbox.LatLng>((coord) {
      return mapbox.LatLng(coord[1], coord[0]);
    }).toList();

    _mapController.clearLines();
    _mapController.addLine(mapbox.LineOptions(
      geometry: route,
      lineColor: "#FF0000",
      lineWidth: 3.0,
    ));

    // Move camera to fit the route
    final bounds = mapbox.LatLngBounds(
      southwest: route.reduce((current, next) => mapbox.LatLng(
        current.latitude < next.latitude ? current.latitude : next.latitude,
        current.longitude < next.longitude ? current.longitude : next.longitude,
      )),
      northeast: route.reduce((current, next) => mapbox.LatLng(
        current.latitude > next.latitude ? current.latitude : next.latitude,
        current.longitude > next.longitude ? current.longitude : next.longitude,
      )),
    );

    _mapController.animateCamera(
      mapbox.CameraUpdate.newLatLngBounds(
        bounds,
        left: 50.0,
        right: 50.0,
        top: 50.0,
        bottom: 50.0,
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchWeather(double lat, double lon) async {
    String apiKey = "6330a41db9409a7a4d193526468a183a";
    final response = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey"));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      double temperature = data['main']['temp'];
      String weatherDescription = data['weather'][0]['description'];

      return {
        'temperature': (temperature - 273.15).toStringAsFixed(2), // Convert from Kelvin to Celsius
        'description': weatherDescription
      };
    } else {
      throw Exception('Failed to fetch weather data.');
    }
  }

  void _showLocationServicesDisabledDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Services Disabled'),
          content: Text('Please enable location services to use this app.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showLocationPermissionsDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Permissions Denied'),
          content: Text('Please grant location permissions to use this app.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _calculateRouteAndWeather() async {
    try {
      final currentPlace = _currentLocationController.text;
      final destinationPlace = _destinationLocationController.text;

      // Fetch coordinates for current location
      final currentCoordinates = await _fetchCoordinates(currentPlace);
      final currentLat = currentCoordinates[1];
      final currentLon = currentCoordinates[0];

      // Fetch coordinates for destination location
      final destinationCoordinates = await _fetchCoordinates(destinationPlace);
      final destinationLat = destinationCoordinates[1];
      final destinationLon = destinationCoordinates[0];

      // Fetch route between current location and destination
      final routeData = await _fetchRoute(currentLat, currentLon, destinationLat, destinationLon);

      // Draw route on map
      _drawRoute(routeData['geometry']);

      // Fetch weather for destination
      final weatherData = await _fetchWeather(destinationLat, destinationLon);

      // Show distance and weather in a dialog
      _showDistanceAndWeatherDialog(routeData['distance'], weatherData);
    } catch (error) {
      // Handle errors
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(error.toString()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  void _showDistanceAndWeatherDialog(double distance, Map<String, dynamic> weatherData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Distance and Weather'),
          content: Text(
            'The distance between the current location and the destination is ${(distance / 1000).toStringAsFixed(2)} kilometers.\n\n'
            'Temperature: ${weatherData['temperature']}°C\n'
            'Weather: ${weatherData['description']}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, 
      appBar: AppBar(
         centerTitle: true,
        backgroundColor:Color.fromRGBO(61,115,127,4),
        title: Text('M A P',
         style: GoogleFonts.lato(
            color: themeManager.themeMode == ThemeMode.light ? Colors.black : Colors.white,
            fontSize: 25,
          ),),
        
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _currentLocationController,
              decoration: InputDecoration(
                hintText: 'Current Location',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _destinationLocationController,
              decoration: InputDecoration(
                hintText: 'Destination Location',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _calculateRouteAndWeather,
              child: Text('Go'),
            ),
          ),
          Expanded(
            child: mapbox.MapboxMap(
              accessToken: _accessToken,
              styleString: mapbox.MapboxStyles.MAPBOX_STREETS,
              onMapCreated: _onMapCreated,
              initialCameraPosition: mapbox.CameraPosition(
                target: mapbox.LatLng(37.7749, -122.4194), // San Francisco coordinates
                zoom: 12.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
