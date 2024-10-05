import 'package:flutter/material.dart';
import 'location_screen.dart';

class AttendanceScreen extends StatelessWidget {
  final List<Map<String, dynamic>> attendanceList = [
    {"name": "Wade Warren (WSL0003)", "checkInTime": "09:30 am", "location": "assets/location.png"},
    {"name": "Esther Howard (WSL0034)", "checkInTime": "09:30 am", "location": "assets/location.png"},
    {"name": "Cameron Williamson (WSL0054)", "checkInTime": "", "location": "assets/location.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance'),
      ),
      body: ListView.builder(
        itemCount: attendanceList.length,
        itemBuilder: (context, index) {
          final member = attendanceList[index];
          return ListTile(
            title: Text(member['name']),
            subtitle: Text('Check-in: ${member['checkInTime']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.location_on),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LocationScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.map),
                  onPressed: () {
                    // This will navigate to the route traveled screen
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
