import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:markstatusapp/db/database_helper.dart';// Ensure you have the correct path to your DatabaseHelper
import 'package:markstatusapp/screens/AllMembersScreen.dart';
import 'package:markstatusapp/screens/SeeRouteScreen.dart';

class TrackLiveLocationScreen extends StatefulWidget {
  final String memberId; // Pass the member ID

  TrackLiveLocationScreen({required this.memberId}); // Constructor to accept memberId

  @override
  _TrackLiveLocationScreenState createState() => _TrackLiveLocationScreenState();
}

class _TrackLiveLocationScreenState extends State<TrackLiveLocationScreen> {
  DateTime selectedDate = DateTime.now(); // To store the selected date
  LatLng? memberLocation; // To store member's location
  List<LatLng> routePoints = []; // To store route points
  String? memberName; // Variable to store member's name
  String? memberId; // Variable to store member's ID
  DateTime? lastLocationUpdateTime; // For tracking last update time
  LatLng? lastLocation; // To store the last known location
  Timer? stopTimer; // Timer to check if the user is stopped
  bool isStopped = false; // Flag to check if the user has stopped
  List<Map<String, String>> sites = []; // List to store site information
  Completer<GoogleMapController> _controller = Completer(); // Completer for Google Maps controller

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked; // Update the selected date
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMemberLocation(); // Fetch location on init
    _startTrackingLocation(); // Start tracking location when screen initializes
  }

  // Fetch latitude, longitude, and route from the attendance database
  Future<void> _fetchMemberLocation() async {
    // Query the attendance table for the member's location using their memberId
    List<Map<String, dynamic>> result = await DatabaseHelper.instance.queryAllRows();
    print("Query Result: $result"); // Debugging line to check what is returned
    var memberRecord = result.firstWhere(
          (record) => record['id'].toString() == widget.memberId,
      orElse: () => {},
    );

    if (memberRecord.isNotEmpty) {
      setState(() {
        // Extract lat and lng and convert them to LatLng
        memberLocation = LatLng(
          double.parse(memberRecord['lat']),
          double.parse(memberRecord['lng']),
        );

        memberName = memberRecord['name'];
        memberId = memberRecord['id'];

        // Manually parse the route if available
        if (memberRecord['route'] != null && memberRecord['route'].isNotEmpty) {
          String routeString = memberRecord['route'];

          // Split the route string by semicolon and convert to LatLng
          List<String> routePairs = routeString.split(';');
          routePoints = routePairs.map((pair) {
            List<String> latLng = pair.split(',');
            return LatLng(double.parse(latLng[0]), double.parse(latLng[1]));
          }).toList();
        }
        sites = [
          {
            'location': '2715 Ash Dr. San Jose, South Dakota 83475',
            'time': 'Left at 08:30 am',
          },
          {
            'location': '1901 Thornridge Cir. Shiloh, Hawaii 81063',
            'time': '09:45 am - 12:45 pm',
          },
          {
            'location': '412 N College Ave, College Place, WA, US',
            'time': '02:15 pm - 02:30 pm',
          },
        ];
      });
    } else {
      print("Member ID not found: ${widget.memberId}"); // Debugging line
    }
  }

  // Function to track location changes
  void _startTrackingLocation() {
    stopTimer = Timer.periodic(Duration(seconds: 30), (timer) async {
      // Simulate getting the current location from a GPS tracker or service
      LatLng currentLocation = await _getCurrentLocation();

      if (lastLocation != null) {
        double distance = _calculateDistance(lastLocation!, currentLocation);
        // If the distance is less than a threshold (10 meters), the user is considered stationary
        if (distance < 10.0) {
          if (!isStopped && lastLocationUpdateTime != null &&
              DateTime.now().difference(lastLocationUpdateTime!).inMinutes >= 10) {
            // The user has stopped for more than 10 minutes, mark it as a stop
            isStopped = true;
            String stopLocation = '${currentLocation.latitude}, ${currentLocation.longitude}';
            String stopDuration = DateTime.now().difference(lastLocationUpdateTime!).inMinutes.toString();
            // Store the stop time in the database
            await DatabaseHelper.instance.insertStop(memberId!, stopLocation, stopDuration);
          }
        } else {
          // User is moving, reset the timer
          isStopped = false;
          lastLocation = currentLocation;
          lastLocationUpdateTime = DateTime.now();
        }
      } else {
        // First location update
        lastLocation = currentLocation;
        lastLocationUpdateTime = DateTime.now();
      }
    });
  }

  Future<LatLng> _getCurrentLocation() async {
    // Simulate a GPS call to get the current location
    // Replace this with actual location fetching logic
    return LatLng(37.7749, -122.4194); // Example coordinates
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    double dLat = (end.latitude - start.latitude) * (3.141592653589793 / 180);
    double dLng = (end.longitude - start.longitude) * (3.141592653589793 / 180);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(start.latitude * (3.141592653589793 / 180)) *
            cos(end.latitude * (3.141592653589793 / 180)) *
            sin(dLng / 2) * sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c * 1000; // Distance in meters
  }

  @override
  void dispose() {
    stopTimer?.cancel(); // Cancel the timer when disposing
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TRACK LIVE LOCATION"),
        backgroundColor: Color(0xFF4334A5),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: memberLocation == null
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Add the member information widget here
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Display profile picture
                CircleAvatar(
                  backgroundImage: AssetImage('assets/Avatar.png'),
                  // Fallback if no image
                  radius: 30,
                ),
                SizedBox(width: 16),
                // Display member name and ID
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$memberName ($memberId)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Handle member change action here
                      },
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AllMembersScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Change",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // The rest of your GoogleMap and other widgets go below
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: memberLocation!,
                    zoom: 12,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId('currentLocation'),
                      position: memberLocation!,
                      infoWindow: InfoWindow(
                        title: memberName ?? 'Member',
                        snippet: 'Last seen 5 min ago',
                      ),
                    ),
                  },
                  polylines: routePoints.isNotEmpty
                      ? {
                    Polyline(
                      polylineId: PolylineId('route'),
                      points: routePoints,
                      color: Colors.blue,
                      width: 5,
                    ),
                  }
                      : {},
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to SeeRouteScreen to show route details
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SeeRouteScreen(
                            memberId: memberId!,
                          ),  // Modify as needed
                        ),
                      );
                    },
                    child: Text("See Route"),
                  ),
                ),
                // Your DraggableScrollableSheet remains here
                DraggableScrollableSheet(
                  initialChildSize: 0.4,
                  minChildSize: 0.2,
                  maxChildSize: 0.8,
                  builder: (BuildContext context, ScrollController scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total Sites: ${sites.length}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _selectDate(context),
                                  child: Row(
                                    children: [
                                      Text(DateFormat('EEE, MMM d yyyy').format(selectedDate)),
                                      SizedBox(width: 8),
                                      Icon(Icons.calendar_today, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: sites.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: Icon(Icons.location_on, color: Colors.blue),
                                  title: Text(sites[index]['location']!), // Location of the site
                                  subtitle: Text(sites[index]['time']!), // Time or date of the site
                                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                                  onTap: () {
                                    // When the ListTile is tapped, navigate to a new screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SeeRouteScreen(
                                          memberId: memberId!, // Pass the memberId here
                                        ), // Modify as needed
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
