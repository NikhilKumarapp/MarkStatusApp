import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:timeline_tile/timeline_tile.dart';

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  GoogleMapController? mapController;

  final LatLng _currentLocation = LatLng(37.7749, -122.4194); // Example coordinates

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 14,
              ),
              onMapCreated: (controller) {
                setState(() {
                  mapController = controller;
                });
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildTimeline(),
          ),
        ],
      ),
    );
  }

  // Timeline to show visited locations
  Widget _buildTimeline() {
    return ListView(
      children: [
        TimelineTile(
          alignment: TimelineAlign.start,
          isFirst: true,
          indicatorStyle: IndicatorStyle(color: Colors.green),
          endChild: Container(
            padding: EdgeInsets.all(8.0),
            child: Text("Location A"),
          ),
        ),
        TimelineTile(
          alignment: TimelineAlign.start,
          indicatorStyle: IndicatorStyle(color: Colors.red),
          endChild: Container(
            padding: EdgeInsets.all(8.0),
            child: Text("Location B"),
          ),
        ),
      ],
    );
  }
}
