import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:sleep_tracker/models/sleep_session.dart';
import 'package:sleep_tracker/providers/settings_provider.dart';
import 'package:sleep_tracker/providers/sleep_provider.dart';
import 'package:sleep_tracker/services/database_helper.dart';
import 'package:sleep_tracker/services/quick_tile.dart';
import 'package:sleep_tracker/utils/formatters.dart';
import 'package:sleep_tracker/utils/sleep_stats.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

SleepSession night(int day, int bedH, int bedM, int minutes, {int? q}) {
  final bed = DateTime(2026, 10, day, bedH, bedM);
  return SleepSession(
    bedTime: bed,
    wakeTime: bed.add(Duration(minutes: minutes)),
    quality: q,
    createdAt: bed,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  setUp(() async {
    DatabaseHelper.pathOverride = inMemoryDatabasePath;
    await DatabaseHelper().close();
  });

  test('start, stop, undo, rate and clear', () async {
    final p = SleepProvider();
    await p.load();
    expect(p.isSleeping, isFalse);

    await p.startSleep(DateTime(2026, 10, 18, 23));
    expect(p.isSleeping, isTrue);

    final done = await p.stopSleep(DateTime(2026, 10, 19, 7));
    expect(p.isSleeping, isFalse);
    expect(p.lastNight!.length, const Duration(hours: 8));
    expect(p.lastNight!.nightDate, DateTime(2026, 10, 19));

    await p.resume(done!);
    expect(p.isSleeping, isTrue);
    await p.stopSleep(DateTime(2026, 10, 19, 7));

    await p.rate(p.lastNight!, 4);
    expect(p.lastNight!.quality, 4);
    await p.rate(p.lastNight!, null);
    expect(p.lastNight!.quality, isNull);

    final s = p.lastNight!;
    await p.delete(s);
    expect(p.nights, isEmpty);
    await p.restore(s);
    expect(p.nights.single.id, s.id);
  });

  test('nap rule: wakes 10am-9pm and under 4h', () {
    bool nap(int bedH, int bedM, int minutes) {
      final n = night(24, bedH, bedM, minutes);
      return SleepSession.looksLikeNap(n.bedTime, n.wakeTime!);
    }

    expect(nap(14, 0, 60), isTrue); // 2pm -> 3pm
    expect(nap(9, 30, 60), isTrue); // 9:30am -> 10:30am
    expect(nap(18, 0, 150), isTrue); // 6pm -> 8:30pm
    expect(nap(13, 0, 240), isFalse); // 4h is not under 4h
    expect(nap(2, 0, 540), isFalse); // 2am -> 11am lie-in
    expect(nap(1, 0, 210), isFalse); // 1am -> 4:30am broken night
    expect(nap(19, 0, 150), isFalse); // wakes 9:30pm
  });

  test('naps stay out of nights', () async {
    final p = SleepProvider();
    await p.load();
    await p.save(night(23, 23, 0, 480)); // wakes Oct 24, 7am
    await p.startSleep(DateTime(2026, 10, 24, 14));
    await p.stopSleep(DateTime(2026, 10, 24, 15));
    expect(p.finished.first.isNap, isTrue);
    expect(p.nights.single.length, const Duration(hours: 8));
    expect(p.lastNight!.nightDate, DateTime(2026, 10, 24));

    // Marking it as a night brings it back.
    await p.save(p.finished.first.copyWith(isNap: false));
    expect(p.nights, hasLength(2));
  });

  test('settings persist', () async {
    final a = SettingsProvider();
    await a.load();
    expect(a.goal, const Duration(hours: 8));
    await a.setGoal(const Duration(hours: 13));
    await a.setRatePrompt(false);
    final b = SettingsProvider();
    await b.load();
    expect(b.goal, SettingsProvider.maxGoal);
    expect(b.ratePrompt, isFalse);
  });

  test('bedtimes around midnight average sensibly', () {
    final list = [night(18, 23, 0, 480), night(19, 1, 0, 420), night(17, 0, 0, 450)];
    expect(usualTimes(list)!.bed, const TimeOfDay(hour: 0, minute: 0));
    expect(usualTimes(list.take(2).toList()), isNull);
    final st = PeriodStats.of(list)!;
    expect(st.average, const Duration(minutes: 450));
    expect(st.longest.length, const Duration(hours: 8));
  });

  test('periods are calendar days by wake date', () {
    final today = DateTime(2026, 10, 19);
    final list = [night(18, 23, 0, 480), night(12, 23, 0, 480), night(11, 23, 0, 480)];
    // Wakes on 19, 13, 12 -> last 7 days = Oct 13..19
    expect(inLastDays(list, today, 7).length, 2);
    expect(inLastDays(list, today, 7, offset: 7).length, 1);
  });

  test('formatters', () {
    expect(fmtDur(const Duration(minutes: 465)), '7h 45m');
    expect(fmtDur(const Duration(hours: 8)), '8h');
    expect(fmtTimer(const Duration(seconds: 3723)), '01:02:03');
  });

  test('quick tile state is decided in Dart', () {
    final n = night(18, 23, 0, 465);
    expect(QuickTile.stateFor(null, null), {
      'active': false,
      'label': 'Start sleep',
      'subtitle': null,
    });
    expect(QuickTile.stateFor(null, n)['subtitle'], 'Last 7h 45m');
    final active = SleepSession(bedTime: DateTime(2026, 10, 19, 23, 2), createdAt: DateTime(2026));
    expect(QuickTile.stateFor(active, n), {
      'active': true,
      'label': 'Sleeping',
      'subtitle': 'Since 11:02 PM',
    });
  });
}
