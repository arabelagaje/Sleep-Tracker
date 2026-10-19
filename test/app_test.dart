import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sleep_tracker/main.dart';
import 'package:sleep_tracker/models/sleep_session.dart';
import 'package:sleep_tracker/providers/settings_provider.dart';
import 'package:sleep_tracker/providers/sleep_provider.dart';
import 'package:sleep_tracker/services/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<(SleepProvider, SettingsProvider)> _pumpApp(WidgetTester tester, int nights) async {
  final sleep = SleepProvider(), settings = SettingsProvider();
  await tester.runAsync(() async {
    DatabaseHelper.pathOverride = inMemoryDatabasePath;
    await DatabaseHelper().close();
    final db = DatabaseHelper();
    final today = DateTime.now();
    for (var i = 0; i < nights; i++) {
      final bed = DateTime(today.year, today.month, today.day - i - 1, 22, 30 + i * 7);
      await db.insertSession(
        SleepSession(
          bedTime: bed,
          wakeTime: bed.add(Duration(minutes: 400 + (i * 37) % 120)),
          quality: i % 3 == 0 ? null : 1 + i % 5,
          notes: i % 4 == 0 ? 'Note $i' : null,
          createdAt: bed,
        ),
      );
    }
    await sleep.load();
    await settings.load();
  });
  await tester.binding.setSurfaceSize(const Size(390, 844));
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sleep),
        ChangeNotifierProvider.value(value: settings),
      ],
      child: const SleepTrackerApp(),
    ),
  );
  await tester.pump();
  return (sleep, settings);
}

Future<void> _visitAll(WidgetTester tester) async {
  for (final tab in ['Log', 'Insights', 'Tonight']) {
    await tester.tap(find.text(tab).last);
    await tester.pump();
  }
  await tester.tap(find.text('Log').last);
  await tester.pump();
  await tester.tap(find.text('Month'));
  await tester.pump();
  for (final p in ['30 days', 'All time']) {
    await tester.tap(find.text('Insights').last);
    await tester.pump();
    await tester.tap(find.text(p));
    await tester.pump();
  }
}

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  for (final n in [0, 2, 30]) {
    testWidgets('all tabs render with $n nights', (tester) async {
      await _pumpApp(tester, n);
      expect(find.text('Start sleep'), findsOneWidget);
      await _visitAll(tester);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('dark theme renders', (tester) async {
    final (_, settings) = await _pumpApp(tester, 30);
    await tester.runAsync(() => settings.setThemeMode(ThemeMode.dark));
    await tester.pump();
    await _visitAll(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings and about open from the menu', (tester) async {
    await _pumpApp(tester, 3);
    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Sleep goal'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.text('Sleep Tracker'), findsOneWidget);
  });

  testWidgets('editor opens for last night and for a new night', (tester) async {
    await _pumpApp(tester, 5);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Delete'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log').last);
    await tester.pump();
    await tester.ensureVisible(find.text('Add a past night'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add a past night'));
    await tester.pumpAndSettle();
    expect(find.text('Delete'), findsNothing);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('sleeping state shows timer', (tester) async {
    final (sleep, _) = await _pumpApp(tester, 3);
    await tester.runAsync(
      () => sleep.startSleep(DateTime.now().subtract(const Duration(minutes: 5))),
    );
    await tester.pump();
    expect(find.text('Tap when you wake'), findsOneWidget);
    expect(find.text('In bed since'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox());
  });
}
