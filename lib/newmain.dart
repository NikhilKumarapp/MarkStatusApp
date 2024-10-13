import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:markstatusapp/db/database_helper.dart'; // Ensure you have the correct path to your DatabaseHelper

class TrackLiveLocationScreen extends StatefulWidget {
  final String memberId; // Pass the member ID

  TrackLiveLocationScreen({required this.memberId}); // Constructor to accept memberId

  @override
  _TrackLiveLocationScreenState createState() => _TrackLiveLocationScreenState();
}

class _TrackLiveLocationScreenState extends State<TrackLiveLocationScreen> {
  DateTime selectedDate = DateTime.now();
  LatLng? memberLocation; // To store member's location
  List<LatLng> routePoints = []; // To store route points
  String? memberName; // Variable to store member's name
  String? memberId; // Variable to store member's ID
  List<Map<String, String>> sites = [];
  Completer<GoogleMapController> _controller = Completer();

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  @override
  void initState() {
    super.initState();
    _fetchMemberLocation(); // Fetch location on init
  }

  // Fetch latitude, longitude, and route from the attendance database
  // Fetch latitude, longitude, and route from the attendance database
  Future<void> _fetchMemberLocation() async {
    // Query the attendance table for the member's location using their memberId
    List<Map<String, dynamic>> result = await DatabaseHelper.instance.queryAllRows();
    print("Query Result: $result"); // Debugging line to check what is returned
    var memberRecord = result.firstWhere(
          (record) => record['id'].toString() == widget.memberId, // Ensure the types match
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Track Live Location"),
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
          : memberLocation!.latitude == 0.0 && memberLocation!.longitude == 0.0 // Example check for valid location
          ? Center(child: Text("No location data found for this member."))
          : Column(
        children: [
          // User Information Section
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/Avatar.png'), // Placeholder for user image
            ),
            title: Text(memberName != null && memberId != null
                ? '$memberName ($memberId)' // Dynamic values
                : 'Member Info', // Fallback text
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: GestureDetector(
              onTap: () {
                // Change user functionality
              },
              child: Text('Change', style: TextStyle(color: Colors.blue)),
            ),
          ),

          // Google Maps Integration
          Container(
            height: 300,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: memberLocation!, // Use fetched member location
                zoom: 12,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('currentLocation'),
                  position: memberLocation!,
                  infoWindow: InfoWindow(
                    title: memberName ?? 'Member',
                    snippet: '5 min ago',
                  ),
                ),
              },
              polylines: {
                if (routePoints.isNotEmpty)
                  Polyline(
                    polylineId: PolylineId('route'),
                    points: routePoints,
                    color: Colors.blue,
                    width: 5,
                  ),
              },
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),

          // Total Sites and Date Selector
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total Sites: 3",
                    style: TextStyle(fontWeight: FontWeight.bold)),
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

          // Sites List
          // Expanded(
          //   child: ListView.builder(
          //     itemCount: sites.length,
          //     itemBuilder: (context, index) {
          //       return ListTile(
          //         leading: Icon(Icons.location_on, color: Colors.blue),
          //         title: Text(sites[index]['location']!),
          //         subtitle: Text(sites[index]['time']!),
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}
