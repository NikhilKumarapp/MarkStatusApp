import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workstatus Menu',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variable to keep track of the selected menu item
  String selectedItem = "Attendance"; // Default active item
  Widget selectedContent = AttendanceContent(); // Default content to show

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance'),
        backgroundColor: Colors.deepPurple,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text("Cameron Williamson"),
              accountEmail: Text("cameronwilliamson@gmail.com"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/Avatar.png'),
              ),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
            ),
            _buildDrawerItem(
              icon: Icons.timer,
              text: 'Timer',
              isSelected: selectedItem == "Timer",
              onTap: () => _onItemSelected("Timer"),
            ),
            _buildDrawerItem(
              icon: Icons.check_box_outlined,
              text: 'Attendance',
              isSelected: selectedItem == "Attendance",
              onTap: () => _onItemSelected("Attendance"),
            ),
            _buildDrawerItem(
              icon: Icons.timeline,
              text: 'Activity',
              isSelected: selectedItem == "Activity",
              onTap: () => _onItemSelected("Activity"),
            ),
            _buildDrawerItem(
              icon: Icons.access_time,
              text: 'Timesheet',
              isSelected: selectedItem == "Timesheet",
              onTap: () => _onItemSelected("Timesheet"),
            ),
            _buildDrawerItem(
              icon: Icons.report,
              text: 'Report',
              isSelected: selectedItem == "Report",
              onTap: () => _onItemSelected("Report"),
            ),
            _buildDrawerItem(
              icon: Icons.location_on,
              text: 'Jobsite',
              isSelected: selectedItem == "Jobsite",
              onTap: () => _onItemSelected("Jobsite"),
            ),
            _buildDrawerItem(
              icon: Icons.people,
              text: 'Team',
              isSelected: selectedItem == "Team",
              onTap: () => _onItemSelected("Team"),
            ),
            _buildDrawerItem(
              icon: Icons.time_to_leave,
              text: 'Time off',
              isSelected: selectedItem == "Time off",
              onTap: () => _onItemSelected("Time off"),
            ),
            _buildDrawerItem(
              icon: Icons.schedule,
              text: 'Schedules',
              isSelected: selectedItem == "Schedules",
              onTap: () => _onItemSelected("Schedules"),
            ),
            Divider(),
            _buildDrawerItem(
              icon: Icons.approval,
              text: 'Request to join Organization',
              isSelected: selectedItem == "approval",
              onTap: () => _onItemSelected("approval"),
            ),
            _buildDrawerItem(
              icon: Icons.lock_outline,
              text: 'Change Password',
              isSelected: selectedItem == "Change Password",
              onTap: () => _onItemSelected("Change Password"),
            ),
            _buildDrawerItem(
              icon: Icons.exit_to_app,
              text: 'Logout',
              isSelected: selectedItem == "Logout",
              onTap: () => _onItemSelected("Logout"),
            ),
            Divider(),
            _buildDrawerItem(
              icon: Icons.help_outline,
              text: 'FAQ & Help',
              isSelected: selectedItem == "FAQ & Help",
              onTap: () => _onItemSelected("FAQ & Help"),
            ),
            _buildDrawerItem(
              icon: Icons.privacy_tip_outlined,
              text: 'Privacy Policy',
              isSelected: selectedItem == "Privacy Policy",
              onTap: () => _onItemSelected("Privacy Policy"),
            ),
            _buildDrawerItem(
              icon: Icons.info_outline,
              text: 'Version: 2.10(1)',
              isSelected: selectedItem == "Version: 2.10(1)",
              onTap: () => _onItemSelected("Version: 2.10(1)"),
            ),
          ],
        ),
      ),
      body: selectedContent, // Display the selected content here
    );
  }

  // Function to build drawer items with a highlight for the selected one
  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required bool isSelected,
    required Function() onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.deepPurple : Colors.black, // Highlight icon if selected
      ),
      title: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.deepPurple : Colors.black, // Highlight text if selected
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.deepPurple.shade100, // Background color for active item
      onTap: onTap,
    );
  }

  // Handle selection of a drawer item
  void _onItemSelected(String item) {
    setState(() {
      selectedItem = item;

      // Switch content based on the selected item
      switch (item) {
        case "Attendance":
          selectedContent = AttendanceContent();
          break;
        case "Timer":
          selectedContent = TimerContent();
          break;
      // Add cases for other menu items like Activity, Timesheet, etc.
        default:
          selectedContent = DefaultContent();
      }
    });
    Navigator.pop(context); // Close the drawer after selection
  }
}

// Sample Widget for Attendance Content
class AttendanceContent extends StatelessWidget {
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

// Sample Widget for Timer Content
class TimerContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Timer Content"),
    );
  }
}

// A default widget to display when no specific content is selected
class DefaultContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Select an item from the menu."),
    );
  }
}
