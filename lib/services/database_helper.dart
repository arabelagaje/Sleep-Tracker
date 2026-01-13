import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/sleep_session.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'sleep_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sleep_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bed_time INTEGER NOT NULL,
        wake_time INTEGER,
        quality INTEGER,
        notes TEXT,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  // Create a new sleep session
  Future<int> insertSession(SleepSession session) async {
    final db = await database;
    return await db.insert('sleep_sessions', session.toMap());
  }

  // Get all sleep sessions
  Future<List<SleepSession>> getAllSessions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sleep_sessions',
      orderBy: 'bed_time DESC',
    );

    return List.generate(maps.length, (i) {
      return SleepSession.fromMap(maps[i]);
    });
  }

  // Get a specific session by ID
  Future<SleepSession?> getSession(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sleep_sessions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return SleepSession.fromMap(maps.first);
  }

  // Get the currently active session (no wake time)
  Future<SleepSession?> getActiveSession() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sleep_sessions',
      where: 'wake_time IS NULL',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return SleepSession.fromMap(maps.first);
  }

  // Update a session
  Future<int> updateSession(SleepSession session) async {
    final db = await database;
    return await db.update(
      'sleep_sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  // Delete a session
  Future<int> deleteSession(int id) async {
    final db = await database;
    return await db.delete(
      'sleep_sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get sessions within a date range
  Future<List<SleepSession>> getSessionsInRange(
      DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sleep_sessions',
      where: 'bed_time >= ? AND bed_time <= ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: 'bed_time DESC',
    );

    return List.generate(maps.length, (i) {
      return SleepSession.fromMap(maps[i]);
    });
  }

  // Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
