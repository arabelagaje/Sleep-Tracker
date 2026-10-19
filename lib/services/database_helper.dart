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

  // Tests point this at an in-memory database
  static String? pathOverride;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    var path = pathOverride;
    if (path == null) {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      path = join(documentsDirectory.path, 'sleep_tracker.db');
    }

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) await _createSettings(db);
  }

  Future<void> _createSettings(Database db) async {
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
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
    await _createSettings(db);
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

  // Get all settings as key/value pairs
  Future<Map<String, String>> getSettings() async {
    final db = await database;
    final rows = await db.query('settings');
    return {for (final r in rows) r['key'] as String: r['value'] as String};
  }

  // Save one setting
  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
