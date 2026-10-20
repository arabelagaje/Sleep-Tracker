import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sleep_tracker/models/sleep_session.dart';
import 'package:sleep_tracker/services/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

SleepSession night(int day) {
  final bed = DateTime(2026, 10, day, 23);
  return SleepSession(
    bedTime: bed,
    wakeTime: bed.add(const Duration(hours: 8)),
    quality: 4,
    createdAt: bed,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory dir;
  final db = DatabaseHelper();

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('backup_test');
    DatabaseHelper.pathOverride = join(dir.path, 'sleep_tracker.db');
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  test('export then import restores sessions and settings', () async {
    await db.insertSession(night(18));
    await db.insertSession(night(19));
    await db.setSetting('goal_minutes', '450');
    final file = join(dir.path, 'backup.db');
    await db.exportTo(file);

    await db.deleteSession((await db.getAllSessions()).first.id!);
    await db.insertSession(night(20));
    await db.setSetting('goal_minutes', '600');
    await db.setSetting('theme_mode', 'dark');

    await db.importFrom(file);
    final sessions = await db.getAllSessions();
    expect(sessions.map((s) => s.bedTime.day), [19, 18]);
    expect(sessions.first.quality, 4);
    expect(await db.getSettings(), {'goal_minutes': '450'});
    expect(File(file).existsSync(), isFalse);

    // The replaced data is kept beside it.
    final previous = await openReadOnlyDatabase('${DatabaseHelper.pathOverride}.bkp');
    expect(await previous.query('sleep_sessions'), hasLength(2));
    await previous.close();
  });

  test('a version 1 backup is migrated', () async {
    final file = join(dir.path, 'v1.db');
    final old = await openDatabase(
      file,
      version: 1,
      onCreate: (d, _) => d.execute('''
        CREATE TABLE sleep_sessions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          bed_time INTEGER NOT NULL,
          wake_time INTEGER,
          quality INTEGER,
          notes TEXT,
          created_at INTEGER NOT NULL
        )
      '''),
    );
    await old.insert('sleep_sessions', night(18).toMap());
    await old.close();
    await db.setSetting('goal_minutes', '600');

    await db.importFrom(file);
    expect((await db.getAllSessions()).single.bedTime.day, 18);
    expect(await db.getSettings(), isEmpty);
  });

  test('bad files are rejected and data is kept', () async {
    await db.insertSession(night(18));

    final junk = join(dir.path, 'junk.db');
    await File(junk).writeAsString('not a database');
    await expectLater(db.importFrom(junk), throwsFormatException);

    final other = join(dir.path, 'other.db');
    final o = await openDatabase(other, version: 1, onCreate: (d, _) => d.execute('CREATE TABLE x (a)'));
    await o.close();
    await expectLater(db.importFrom(other), throwsFormatException);

    final newer = join(dir.path, 'newer.db');
    await db.exportTo(newer);
    final n = await openDatabase(newer);
    await n.setVersion(DatabaseHelper.schemaVersion + 1);
    await n.close();
    await expectLater(db.importFrom(newer), throwsFormatException);

    expect(dir.listSync().map((f) => basename(f.path)), ['sleep_tracker.db']);
    expect((await db.getAllSessions()).single.bedTime.day, 18);
  });
}
