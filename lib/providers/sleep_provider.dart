import 'package:flutter/foundation.dart';

import '../models/sleep_session.dart';
import '../services/database_helper.dart';
import '../services/quick_tile.dart';

class SleepProvider extends ChangeNotifier {
  SleepProvider([DatabaseHelper? db]) : _db = db ?? DatabaseHelper();

  final DatabaseHelper _db;

  bool _loading = true;
  List<SleepSession> _finished = [];
  List<SleepSession> _nights = [];
  SleepSession? _active;

  bool get isLoading => _loading;
  bool get isSleeping => _active != null;
  SleepSession? get active => _active;

  // Finished sessions, naps included, newest wake-up first.
  List<SleepSession> get finished => _finished;

  // Finished sessions without naps, newest wake-up first. Stats and charts use these.
  List<SleepSession> get nights => _nights;
  SleepSession? get lastNight => _nights.isEmpty ? null : _nights.first;

  Future<void> load() async {
    final all = await _db.getAllSessions();
    _active = all.where((s) => s.isActive).firstOrNull;
    _finished = all.where((s) => !s.isActive).toList()
      ..sort((a, b) => b.wakeTime!.compareTo(a.wakeTime!));
    _nights = _finished.where((s) => !s.isNap).toList();
    _loading = false;
    notifyListeners();
    await QuickTile.push(_active, lastNight);
  }

  Future<void> startSleep([DateTime? at]) async {
    final now = DateTime.now();
    await _db.insertSession(SleepSession(bedTime: at ?? now, createdAt: now));
    await load();
  }

  // Ends the running session and returns it.
  Future<SleepSession?> stopSleep([DateTime? at]) async {
    final a = _active;
    if (a == null) return null;
    final wake = at ?? DateTime.now();
    final done = a.copyWith(wakeTime: wake, isNap: SleepSession.looksLikeNap(a.bedTime, wake));
    await _db.updateSession(done);
    await load();
    return done;
  }

  // Undo for a stop: the session keeps running.
  Future<void> resume(SleepSession session) async {
    await _db.updateSession(session.copyWith(clearWakeTime: true));
    await load();
  }

  // Inserts when id is null, otherwise updates. Returns the saved session.
  Future<SleepSession> save(SleepSession session) async {
    var saved = session;
    if (session.id == null) {
      saved = session.copyWith(id: await _db.insertSession(session));
    } else {
      await _db.updateSession(session);
    }
    await load();
    return saved;
  }

  Future<void> rate(SleepSession session, int? quality) => save(
    quality == null ? session.copyWith(clearQuality: true) : session.copyWith(quality: quality),
  );

  Future<void> delete(SleepSession session) async {
    await _db.deleteSession(session.id!);
    await load();
  }

  // Undo for a delete: puts the row back with its old id.
  Future<void> restore(SleepSession session) async {
    await _db.insertSession(session);
    await load();
  }
}
