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

  // The quick tile's background engine sets this to false so it gets its own
  // connection instead of sharing the app's, which an import closes.
  static bool singleInstance = true;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<String> filePath() async =>
      pathOverride ?? join((await getApplicationDocumentsDirectory()).path, 'sleep_tracker.db');

  Future<Database> _initDatabase() async {
    return await openDatabase(
      await filePath(),
      version: schemaVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      singleInstance: singleInstance,
    );
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

  // Copies the database file to [to].
  Future<void> exportTo(String to) async {
    final db = await database;
    // Moves changes still in the write-ahead log, if any, into the file.
    await db.rawQuery('PRAGMA wal_checkpoint(TRUNCATE)');
    await File(await filePath()).copy(to);
  }

  // Puts the backup file [incoming] in place of the database file and opens
  // it; an older backup is brought up to date by the regular migrations. The
  // replaced file is kept as `.bkp` until the next import. [incoming] is
  // moved or deleted either way.
  // Throws [FormatException] when it isn't a usable backup; the current data
  // is left untouched in that case.
  Future<void> importFrom(String incoming) async {
    try {
      await _check(incoming);
    } catch (_) {
      await File(incoming).delete();
      rethrow;
    }

    final path = await filePath();
    final previous = '$path.bkp';
    await close();
    await _deleteSideFiles(path);
    await File(path).rename(previous);
    await File(incoming).rename(path);
    try {
      await database;
    } catch (_) {
      await _deleteSideFiles(path);
      await File(previous).rename(path);
      rethrow;
    }
  }

  Future<void> _check(String file) async {
    const notOurs = FormatException('Not a Sleep Tracker backup');
    final Database db;
    try {
      db = await openReadOnlyDatabase(file, singleInstance: false);
    } on DatabaseException {
      throw notOurs;
    }
    try {
      final tables = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'sleep_sessions'],
      );
      if (tables.isEmpty) throw notOurs;
      if (await db.getVersion() > schemaVersion) {
        throw const FormatException('Backup is from a newer app version');
      }
    } on DatabaseException {
      throw notOurs;
    } finally {
      await db.close();
    }
  }

  // SQLite's journal files, which belong to the file being replaced.
  Future<void> _deleteSideFiles(String path) async {
    for (final suffix in ['-journal', '-wal', '-shm']) {
      final f = File('$path$suffix');
      if (await f.exists()) await f.delete();
    }
  }

  // Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
