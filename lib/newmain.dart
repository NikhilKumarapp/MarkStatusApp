import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: AttendancePage(),
    );
  }
}

class AttendancePage extends StatefulWidget {
  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Members'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              // Add calendar functionality here
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Tue, Aug 31 2022',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        children: [
          buildAttendanceItem(
              "Wade Warren",
              "WSL0003",
              "assets/avatar1.png",
              "09:30 am",
              "Working",
              Colors.green,
              true),
          buildAttendanceItem(
              "Esther Howard",
              "WSL0034",
              "assets/avatar2.png",
              "09:30 am",
              "06:40 pm",
              Colors.red,
              false),
          buildAttendanceItem(
              "Cameron Williamson",
              "WSL0054",
              "assets/avatar3.png",
              "Not logged in yet",
              null,
              Colors.grey,
              false),
          buildAttendanceItem(
              "Brooklyn Simmons",
              "WSL0076",
              "assets/avatar4.png",
              "09:30 am",
              "06:40 pm",
              Colors.red,
              false),
          buildAttendanceItem(
              "Savannah Nguyen",
              "WSL0065",
              "assets/avatar5.png",
              "09:30 am",
              "06:40 pm",
              Colors.red,
              false),
        ],
      ),
    );
  }

  // Function to build each attendance item
  Widget buildAttendanceItem(String name, String id, String avatarPath, String checkInTime,
      String? status, Color statusColor, bool isWorking) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(avatarPath),
            radius: 24,
          ),
          title: Row(
            children: [
              Text(name),
              SizedBox(width: 8),
              Text(
                "($id)",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          subtitle: Row(
            children: [
              Text(checkInTime),
              SizedBox(width: 10),
              if (status != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: statusColor),
                  ),
                )
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.schedule, color: Colors.grey),
                onPressed: () {
                  // Add schedule functionality here
                },
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: Colors.grey),
                onPressed: () {
                  // Add more options functionality here
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
