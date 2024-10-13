import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:markstatusapp/db/database_helper.dart'; // Adjust the path if necessary
import 'AllMembersScreen.dart'; // Adjust the path if necessary

class SeeRouteScreen extends StatefulWidget {
  final String memberId;

  const SeeRouteScreen({Key? key, required this.memberId}) : super(key: key);

  @override
  _SeeRouteScreenState createState() => _SeeRouteScreenState();
}

class _SeeRouteScreenState extends State<SeeRouteScreen> {
  GoogleMapController? mapController;
  LatLng _initialPosition = LatLng(28.6139, 77.2090); // Default position (Delhi)
  LatLng? _startLocation;
  LatLng? _endLocation;
  List<LatLng> routeCoords = [];

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  String memberName = 'Loading...';
  double totalKms = 0.0;
  String totalDuration = 'Calculating...';

  @override
  void initState() {
    super.initState();
    _loadMemberData();
    _requestLocationPermission();
  }

  Future<void> _loadMemberData() async {
    // Fetch member data from the database
    List<Map<String, dynamic>> memberData = await DatabaseHelper.instance.queryMemberById(widget.memberId);

    if (memberData.isNotEmpty) {
      setState(() {
        memberName = memberData[0]['name'] ?? 'Unknown';
      });

      // Parse the route and calculate the total distance
      String? routeString = memberData[0]['route'];
      if (routeString != null && routeString.isNotEmpty) {
        _calculateTotalDistanceAndDuration(routeString);
        _setStartAndEndLocation(routeString);
      }
    }
  }

  void _calculateTotalDistanceAndDuration(String routeString) {
    List<String> coordinates = routeString.split(';');
    double totalDistance = 0.0;
    if (coordinates.length < 2) {
      print("Not enough coordinates to calculate distance.");
      return;
    }
    for (int i = 0; i < coordinates.length - 1; i++) {
      LatLng point1 = _parseLatLng(coordinates[i]);
      LatLng point2 = _parseLatLng(coordinates[i + 1]);
      totalDistance += _calculateDistance(point1, point2);
    }
    setState(() {
      totalKms = totalDistance;
      totalDuration = _estimateDuration(totalDistance);
    });
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    const double R = 6371.0; // Radius of Earth in kilometers
    double dLat = _degToRad(point2.latitude - point1.latitude);
    double dLon = _degToRad(point2.longitude - point1.longitude);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(point1.latitude)) * cos(_degToRad(point2.latitude)) *
            sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degToRad(double degree) {
    return degree * pi / 180;
  }

  String _estimateDuration(double distanceInKm) {
    // Assuming an average speed of 40 km/h
    double hours = distanceInKm / 40.0;
    int totalMinutes = (hours * 60).round();
    int hoursPart = totalMinutes ~/ 60;
    int minutesPart = totalMinutes % 60;
    return '${hoursPart}h ${minutesPart}m';
  }

  void _setStartAndEndLocation(String routeString) {
    List<String> coordinates = routeString.split(';');
    if (coordinates.length >= 2) {
      _startLocation = _parseLatLng(coordinates.first);
      _endLocation = _parseLatLng(coordinates.last);
      _addMarkers();
      _addLineBetweenStartAndEnd(); // Draw the line between start and end locations
    }
  }

  LatLng _parseLatLng(String coord) {
    List<String> latLng = coord.split(',');
    return LatLng(double.parse(latLng[0]), double.parse(latLng[1]));
  }

  void _addMarkers() {
    if (_startLocation != null) {
      markers.add(Marker(
        markerId: MarkerId('start'),
        position: _startLocation!,
        infoWindow: InfoWindow(title: 'Start Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    }

    if (_endLocation != null) {
      markers.add(Marker(
        markerId: MarkerId('end'),
        position: _endLocation!,
        infoWindow: InfoWindow(title: 'End Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }

    setState(() {});
  }

  void _addLineBetweenStartAndEnd() {
    if (_startLocation != null && _endLocation != null) {
      polylines.add(Polyline(
        polylineId: PolylineId('line_between_start_and_end'),
        points: [_startLocation!, _endLocation!],
        color: Colors.blue,
        width: 4,
      ));
      setState(() {});
    }
  }

  Future<void> _requestLocationPermission() async {
    if (await Permission.location.request().isGranted) {
      _trackUserLocation();
    } else {
      print("Location permission denied.");
      openAppSettings();
    }
  }

  void _trackUserLocation() {
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((Position position) {
      LatLng currentPosition = LatLng(position.latitude, position.longitude);
      mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: currentPosition, zoom: 14)));

      markers.add(Marker(
        markerId: MarkerId('currentLocation'),
        position: currentPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(title: 'You are here'),
      ));
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('See Route'),
        backgroundColor: const Color(0xFF4334A5),
      ),
      body: Column(
        children: [
          _buildInfoCard(),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 10),
              markers: markers,
              polylines: polylines,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: const AssetImage('assets/Avatar.png'), // Update with your image path
                    radius: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      memberName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AllMembersScreen()),
                      );
                    },
                    child: const Text(
                      "Change",
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Kms: ${totalKms.toStringAsFixed(2)} km'),
                  Text('Total Duration: $totalDuration'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
