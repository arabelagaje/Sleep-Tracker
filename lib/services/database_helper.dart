import 'dart:io';

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

    return await openDatabase(path, version: schemaVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  static const schemaVersion = 2;

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
    return await db.delete('sleep_sessions', where: 'id = ?', whereArgs: [id]);
  }

  // Get sessions within a date range
  Future<List<SleepSession>> getSessionsInRange(DateTime start, DateTime end) async {
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
    await db.insert('settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Writes a standalone copy of the whole database to [path].
  Future<void> exportTo(String path) async {
    final db = await database;
    final file = File(path);
    if (await file.exists()) await file.delete();
    await db.execute('VACUUM INTO ?', [path]);
  }

  // Replaces all sessions and settings with those in the database file at
  // [path]. The file is migrated in place first if it comes from an older app
  // version, so pass a copy.
  // Throws [FormatException] when the file isn't a usable backup; the current
  // data is left untouched in that case.
  Future<void> importFrom(String path) async {
    final Database src;
    try {
      src = await openReadOnlyDatabase(path);
    } on DatabaseException {
      throw const FormatException('Not a Sleep Tracker backup');
    }
    try {
      final version = await src.getVersion();
      final tables = await src.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'sleep_sessions'],
      );
      if (tables.isEmpty) throw const FormatException('Not a Sleep Tracker backup');
      if (version > schemaVersion) {
        throw const FormatException('Backup is from a newer app version');
      }
    } on DatabaseException {
      throw const FormatException('Not a Sleep Tracker backup');
    } finally {
      await src.close();
    }

    // Bring the file up to the current schema with the regular migrations.
    final migrated = await openDatabase(path, version: schemaVersion, onUpgrade: _onUpgrade);
    await migrated.close();

    final db = await database;
    await db.execute('ATTACH DATABASE ? AS src', [path]);
    try {
      await db.transaction((txn) async {
        await txn.delete('sleep_sessions');
        await txn.delete('settings');
        await txn.execute('''
          INSERT INTO sleep_sessions (id, bed_time, wake_time, quality, notes, created_at)
          SELECT id, bed_time, wake_time, quality, notes, created_at FROM src.sleep_sessions
        ''');
        await txn.execute('INSERT INTO settings (key, value) SELECT key, value FROM src.settings');
      });
    } finally {
      await db.execute('DETACH DATABASE src');
    }
  }

  // Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
