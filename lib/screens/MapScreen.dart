import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:markstatusapp/db/database_helper.dart';
import 'package:markstatusapp/screens/AllMembersScreen.dart';
import 'package:markstatusapp/screens/AttendanceContent.dart';

import '../newmain.dart'; // Make sure you have AllMembersScreen implemented

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  Set<Marker> _markers = {}; // Store the markers here
  final LatLng _center = const LatLng(37.7749, -122.4194); // Default location

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData(); // Load data and populate markers
  }

  // Fetch attendance data from the database and create markers
  void _fetchAttendanceData() async {
    List<Map<String, dynamic>> attendanceRecords =
    await DatabaseHelper.instance.queryAllRows();

    Set<Marker> markers = attendanceRecords.map((record) {
      return Marker(
        markerId: MarkerId(record['id']),
        position: LatLng(
          double.parse(record['lat']), // Latitude from the record
          double.parse(record['lng']), // Longitude from the record
        ),
        infoWindow: InfoWindow(
          title: record['name'], // Member name from the record
          snippet: 'Status: ${record['status']}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet),
        onTap: () {
          // You can pass the ID here when tapped
          _onMarkerTap(record['id']);
        },
      );
    }).toSet();

    setState(() {
      _markers = markers;
    });
  }

  // Navigate to another screen or show info when a marker is tapped
  void _onMarkerTap(String id) {
    // Navigate to the screen where you track live location or perform other actions
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrackLiveLocationScreen(memberId: id),
      ),
    );
  }

  // When the map is created
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4334A5),
        title: Text('ATTENDANCE'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: [],
      ),
      body: Stack(
        children: [
          // Google Maps widget
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 13.0,
            ),
            markers: _markers,
          ),

          // Top Center - All Members Header
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              padding: EdgeInsets.all(10),
              color: Colors.deepPurple[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.people),
                      SizedBox(width: 8),
                      Text(
                        "All Members",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // Change logic or navigation
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AllMembersScreen()),
                      );
                    },
                    child: Text(
                      "Change",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Center - Show List View button
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ListTile(
                onTap: () {
                  // Navigate to list view screen
                  Navigator.pop(context);
                },
                title: Text(
                  'Show List view',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.purple,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
