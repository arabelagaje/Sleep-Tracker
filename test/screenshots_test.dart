// Renders the README screenshots from the real widgets with sample data.
// Skipped in a normal test run; regenerate with:
//   flutter test test/screenshots_test.dart --update-goldens
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sleep_tracker/main.dart';
import 'package:sleep_tracker/models/sleep_session.dart';
import 'package:sleep_tracker/providers/settings_provider.dart';
import 'package:sleep_tracker/providers/sleep_provider.dart';
import 'package:sleep_tracker/services/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// flutter_test draws every font as boxes until the real ones are loaded.
Future<void> _loadFonts() async {
  final manifest = jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final family in manifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(family['family'] as String);
    for (final font in (family['fonts'] as List).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}

// Five weeks of plausible nights, a little later at weekends, plus one nap.
Future<void> _seed() async {
  final db = DatabaseHelper();
  final today = DateTime.now();
  for (var i = 1; i <= 35; i++) {
    final day = DateTime(today.year, today.month, today.day - i);
    final weekend = day.weekday == DateTime.friday || day.weekday == DateTime.saturday;
    final bed = day.add(Duration(hours: 22, minutes: (weekend ? 95 : 35) + (i * 17) % 40));
    final length = Duration(minutes: 395 + (i * 41) % 95 + (weekend ? 45 : 0));
    await db.insertSession(
      SleepSession(
        bedTime: bed,
        wakeTime: bed.add(length),
        quality: i % 4 == 3 ? null : 3 + (i * 7) % 3,
        createdAt: bed,
      ),
    );
  }
  final napBed = DateTime(today.year, today.month, today.day - 2, 14, 20);
  await db.insertSession(
    SleepSession(
      bedTime: napBed,
      wakeTime: napBed.add(const Duration(minutes: 50)),
      isNap: true,
      createdAt: napBed,
    ),
  );
}

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  testWidgets('README screenshots', skip: !autoUpdateGoldenFiles, (tester) async {
    final sleep = SleepProvider(), settings = SettingsProvider();
    await tester.runAsync(() async {
      await _loadFonts();
      DatabaseHelper.pathOverride = inMemoryDatabasePath;
      await DatabaseHelper().close();
      await _seed();
      await sleep.load();
      await settings.load();
      await settings.setThemeMode(ThemeMode.light);
    });
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: sleep),
          ChangeNotifierProvider.value(value: settings),
        ],
        child: const SleepTrackerApp(),
      ),
    );
    await tester.pumpAndSettle();

    Future<void> shot(String name) async {
      await tester.pumpAndSettle();
      await expectLater(find.byType(SleepTrackerApp), matchesGoldenFile('../docs/screenshots/$name.png'));
    }

    Future<void> tab(String name) async {
      await tester.tap(find.text(name).last);
      await tester.pumpAndSettle();
    }

    for (final (mode, suffix) in [(ThemeMode.light, ''), (ThemeMode.dark, '-dark')]) {
      await tester.runAsync(() => settings.setThemeMode(mode));
      await tab('Tonight');
      await shot('tonight$suffix');
      await tab('Log');
      await tester.tap(find.text('Timeline'));
      await shot('log$suffix');
      await tester.tap(find.text('Calendar'));
      await shot('calendar$suffix');
      await tab('Insights');
      await tester.tap(find.text('30 days'));
      await shot('insights$suffix');
    }
  });
}
