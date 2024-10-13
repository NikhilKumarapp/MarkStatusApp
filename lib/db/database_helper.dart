import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = "AttendanceDatabase.db";
  static final _databaseVersion = 1;

  static final table = 'attendance';

  // Column names
  static final columnId = 'id'; // Changed from _id to id
  static final columnName = 'name';
  static final columnCheckIn = 'checkIn';
  static final columnCheckOut = 'checkOut';
  static final columnStatus = 'status';
  static final columnLat = 'lat'; // New column for latitude
  static final columnLng = 'lng'; // New column for longitude
  static final columnRoute = 'route'; // New column for travel route
  static final columnStopTime = 'stopTime';
  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  // Database accessor
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  // Create the table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId TEXT PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnCheckIn TEXT NOT NULL,
        $columnCheckOut TEXT,
        $columnStatus TEXT NOT NULL,
        $columnLat TEXT, 
        $columnLng TEXT,  
        $columnRoute TEXT,
        $columnStopTime TEXT  
      )
    ''');
  }

  // Insert a single record
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  // Insert multiple records
  Future<void> insertMultiple(List<Map<String, dynamic>> rows) async {
    Database db = await instance.database;
    Batch batch = db.batch();
    rows.forEach((row) {
      batch.insert(table, row);
    });
    await batch.commit(noResult: true); // Batch insert, no need for results
  }

  // Fetch all records
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // Fetch records for a specific date
  Future<List<Map<String, dynamic>>> queryRecordsByDate(String date) async {
    Database db = await instance.database;
    return await db.query(
      table,
      where: '$columnCheckIn LIKE ?',
      whereArgs: ['%$date%'], // Assumes checkIn contains the date as part of the string
    );
  }

  // Optional: A method to delete all records (useful for testing)
  Future<void> deleteAllRecords() async {
    Database db = await instance.database;
    await db.delete(table);
  }

  // Optional: A method to delete the database (useful for resetting)
  Future<void> deleteDatabase(Comparable<String> path) async {
    String path = join(await getDatabasesPath(), _databaseName);
    await deleteDatabase(path);
  }
  // Method to insert stop details
  Future<void> insertStop(String memberId, String stopLocation, String stopDuration) async {
    Database db = await instance.database;
    await db.update(
      table,
      {columnStopTime: '$stopLocation: $stopDuration'},
      where: '$columnId = ?',
      whereArgs: [memberId],
    );
  }

  // In your DatabaseHelper class
  Future<List<Map<String, dynamic>>> queryMemberById(String memberId) async {
    Database db = await instance.database;

    // Query the database where the id matches the memberId
    return await db.query(
      'attendance', // Your table name
      where: 'id = ?', // Specify the member ID
      whereArgs: [memberId], // Pass the memberId as an argument
    );
  }

  // Method to get member's location by ID
  Future<Map<String, dynamic>?> getMemberLocationById(String memberId) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> results = await db.query(
      table,
      where: '$columnId = ?',
      whereArgs: [memberId],
    );

    if (results.isNotEmpty) {
      return results.first; // Return the first match
    }
    return null; // Return null if no match found
  }

  // Method to get member's route by ID
  Future<String?> getMemberRouteById(String memberId) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> results = await db.query(
      table,
      columns: [columnRoute],
      where: '$columnId = ?',
      whereArgs: [memberId],
    );

    if (results.isNotEmpty) {
      return results.first[columnRoute]; // Return the route string
    }
    return null; // Return null if no match found
  }



}
