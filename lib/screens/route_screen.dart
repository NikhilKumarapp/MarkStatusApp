import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteScreen extends StatefulWidget {
  @override
  _RouteScreenState createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  GoogleMapController? mapController;
  List<LatLng> routeCoordinates = [
    LatLng(37.7749, -122.4194), // Start location
    LatLng(37.7849, -122.4094), // End location
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route Traveled'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: routeCoordinates.first,
          zoom: 12,
        ),
        onMapCreated: (controller) {
          setState(() {
            mapController = controller;
          });
        },
        polylines: {
          Polyline(
            polylineId: PolylineId('route'),
            points: routeCoordinates,
            color: Colors.blue,
            width: 5,
          ),
        },
      ),
    );
  }
}
