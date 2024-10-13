import 'package:flutter/material.dart';
import 'package:markstatusapp/db/database_helper.dart';
import 'package:markstatusapp/screens/TrackLiveLocationScreen.dart';

class AllMembersScreen extends StatefulWidget {
  @override
  _AllMemberContentState createState() => _AllMemberContentState();
}

class _AllMemberContentState extends State<AllMembersScreen> {
  List<Map<String, dynamic>> members = [];
  List<Map<String, dynamic>> filteredMembers = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMembers(); // Load members from the database
    searchController.addListener(() {
      filterMembers();
    });
  }

  // Function to load members from the attendance table
  Future<void> _loadMembers() async {
    final dbHelper = DatabaseHelper.instance;
    List<Map<String, dynamic>> records = await dbHelper.queryAllRows();
    setState(() {
      members = records
          .map((record) => {
        'id': record['id'],  // Assuming 'id' is the field in the database
        'name': record['name'],
      }).toList();
      filteredMembers = members;  // Initialize filtered members with all members
    });
  }

  // Function to filter members based on search input
  void filterMembers() {
    final query = searchController.text;
    if (query.isNotEmpty) {
      filteredMembers = members
          .where((member) => member['name']
          .toLowerCase()
          .contains(query.toLowerCase()))
          .toList();
    } else {
      filteredMembers = members;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Members'),
        backgroundColor: Color(0xFF4334A5),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.grey[200],
                filled: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(Icons.people, color: Color(0xFF4334A5)),
              title: Text(
                'All Members',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF4334A5)),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredMembers.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Text(filteredMembers[index]['name'][0]), // Use name's first letter
                        ),
                        title: Text(filteredMembers[index]['name']),
                        onTap: () {
                          // Navigate to the TrackLiveLocationScreen and pass the member's ID
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TrackLiveLocationScreen(
                                memberId: filteredMembers[index]['id'].toString(), // Pass the correct 'id'
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
