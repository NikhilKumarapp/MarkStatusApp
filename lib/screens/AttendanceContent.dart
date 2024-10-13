import 'package:flutter/material.dart';
import 'package:markstatusapp/screens/AllMembersScreen.dart';
import 'package:markstatusapp/screens/MapScreen.dart';
import "package:intl/intl.dart";
import 'package:markstatusapp/screens/TrackLiveLocationScreen.dart';
import 'package:markstatusapp/db/database_helper.dart';

class AttendanceContent extends StatefulWidget {
  @override
  _AttendanceContentState createState() => _AttendanceContentState();
}

class _AttendanceContentState extends State<AttendanceContent> {
  DateTime selectedDate = DateTime.now();
  DateTime _currentDate = DateTime.now(); // Initialize with current date

  List<Map<String, dynamic>> attendanceRecords = []; // Empty list to hold data from SQLite

  // Your static list of records with date and time in correct format
  final List<Map<String, dynamic>> initialRecords = [
    {
      "id": "WSL0051",
      "name": "Wade Warren",
      "checkIn": "2024-10-05 09:30:00", // Ensure this format
      "checkOut": "2024-10-05 18:40:00",
      "status": "WORKING",
      'lat': '37.7749',  // Latitude value
      'lng': '-122.4194',  // Longitude value
      'route': '37.7749,-122.4194;37.7849,-122.4094',
    },
    {
      "id": "WSL0052",
      "name": "Esther Howard",
      "checkIn": "2024-10-05 09:30:00",
      "checkOut": "2024-10-05 18:40:00",
      "status": "NOT WORKING",
      'lat': '38.7749',  // Latitude value
      'lng': '-122.4194',  // Longitude value
      'route': '38.7749,-122.4194;39.7849,-122.4094',
    },
    {
      "id": "WSL0053",
      "name": "Vinove Kumar",
      "checkIn": "2024-10-05 08:45:00",
      "checkOut": "2024-10-05 16:30:00",
      "status": "WORKING",
      'lat': '35.7749',  // Latitude value
      'lng': '-122.4194',  // Longitude value
      'route': '35.7749,-122.4194;36.7849,-122.4094',
    },
    {
      "id": "WSL0054",
      "name": "Robert Downey",
      "checkIn": "2024-10-05 10:00:00",
      "checkOut": "2024-10-05 19:15:00",
      "status": "NOT WORKING",
      'lat': '40.7749',  // Latitude value
      'lng': '-122.4194',  // Longitude value
      'route': '38.7749,-122.4194;40.7849,-122.4094',
    },
  ];

  // Function to load attendance records for a specific date
  Future<void> _loadAttendanceRecords(String date) async {
    final dbHelper = DatabaseHelper.instance;
    List<Map<String, dynamic>> records = await dbHelper.queryRecordsByDate(date);
    setState(() {
      attendanceRecords = records;
    });
  }

  // Function to format date for SQLite queries
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date); // Format to match your checkIn date format in SQLite
  }

  // Function to insert initial records into SQLite
  Future<void> _insertInitialRecords() async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.insertMultiple(initialRecords); // Insert the static records into the database
  }

  @override
  void initState() {
    super.initState();
    _insertInitialRecords(); // Insert initial records when the widget is first loaded
    _loadAttendanceRecords(_formatDate(_currentDate)); // Load today's records on initialization
  }

  // Function to go back one day and load data
  void _goBackOneDay() {
    setState(() {
      _currentDate = _currentDate.subtract(Duration(days: 1));
    });
    _loadAttendanceRecords(_formatDate(_currentDate));
  }

  // Function to go forward one day and load data
  void _goForwardOneDay() {
    setState(() {
      _currentDate = _currentDate.add(Duration(days: 1));
    });
    _loadAttendanceRecords(_formatDate(_currentDate));
  }

  // Function to open date picker and load data for selected date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _currentDate = picked;
      });
      _loadAttendanceRecords(_formatDate(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEE, MMM d, yyyy').format(_currentDate);

    return Scaffold(
      body: Column(
        children: [
          // Member selection and navigation row
          Container(
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
                )
              ],
            ),
          ),

          // Date navigation and selection row
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: _goBackOneDay,
                  tooltip: 'Go back one day',
                ),
                Text(
                  formattedDate,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: _goForwardOneDay,
                  tooltip: 'Go forward one day',
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                  tooltip: 'Select a date',
                ),
              ],
            ),
          ),

          // Attendance records list
          Expanded(
            child: ListView.builder(
              itemCount: attendanceRecords.length,
              itemBuilder: (context, index) {
                // Attendance record item
                final record = attendanceRecords[index];
                return attendanceCard(
                  record["id"] ?? "1",
                  record["name"],
                  record["checkIn"],
                  record["checkOut"],
                  record["status"],
                  record["status"] == "WORKING" ? Colors.green : Colors.red,
                  record["status"] == "WORKING" ? Icons.check_circle : Icons.cancel,
                );

              },
            ),

          ),

          // "Show Map view" ListTile at the bottom
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListTile(
              title: Text(
                "Show Map view",
                style: TextStyle(
                  color: Colors.deepPurple[400],
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.blue),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Updated attendanceCard to show only time for checkIn and checkOut
  Widget attendanceCard(String id, String name, String checkIn, String checkOut,
      String status, Color statusColor, IconData statusIcon) {

    // Parse checkIn and checkOut to DateTime and format only time
    DateTime checkInTime = DateTime.parse(checkIn);
    DateTime checkOutTime = DateTime.parse(checkOut);

    String formattedCheckIn = DateFormat('hh:mm a').format(checkInTime);
    String formattedCheckOut = DateFormat('hh:mm a').format(checkOutTime);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$name ($id)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Icon(Icons.arrow_upward, color: Colors.green),
                        SizedBox(width: 5),
                        Text(formattedCheckIn), // Updated to show only time
                        SizedBox(width: 20),
                        if (formattedCheckOut.isNotEmpty)
                          Row(
                            children: [
                              Icon(Icons.arrow_downward, color: Colors.red),
                              SizedBox(width: 5),
                              Text(formattedCheckOut), // Updated to show only time
                            ],
                          ),
                        IconButton(
                          icon: Icon(Icons.my_location),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TrackLiveLocationScreen(memberId: '$id',), // Navigate to live location
                              ),
                            );
                          },
                          tooltip: 'Go to live location',
                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context),
                          tooltip: 'Select a date',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(statusIcon, color: statusColor),
            ],
          ),
        ),
      ),
    );
  }
}
