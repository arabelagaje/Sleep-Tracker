import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_tracker/l10n/l10n.dart';
import 'package:sleep_tracker/utils/formatters.dart';

void main() {
  Future<BuildContext> pumpWith(WidgetTester tester, bool use24h, [String lang = 'en']) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      Localizations(
        locale: Locale(lang),
        delegates: AppLocalizations.localizationsDelegates,
        child: MediaQuery(
          data: MediaQueryData(alwaysUse24HourFormat: use24h),
          child: Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    await tester.pump();
    return ctx;
  }

  testWidgets('12-hour phone', (tester) async {
    final c = await pumpWith(tester, false);
    expect(fmtClock(c, DateTime(2026, 1, 1, 23, 43)), '11:43 PM');
    expect(fmtTimeOfDay(c, const TimeOfDay(hour: 7, minute: 5)), '7:05 AM');
    expect([18, 0, 9, 12].map((h) => fmtAxisHour(c, h)), ['6p', '12a', '9a', '12p']);
  });

  testWidgets('24-hour phone', (tester) async {
    final c = await pumpWith(tester, true);
    expect(fmtClock(c, DateTime(2026, 1, 1, 23, 43)), '23:43');
    expect(fmtTimeOfDay(c, const TimeOfDay(hour: 7, minute: 5)), '07:05');
    expect([18, 0, 9, 12].map((h) => fmtAxisHour(c, h)), ['18', '00', '09', '12']);
  });

  testWidgets('dates in English', (tester) async {
    final l = (await pumpWith(tester, false)).l10n;
    final d = DateTime(2026, 10, 18);
    expect(fmtDay(l, d), 'Sun, Oct 18');
    expect(fmtMonthDay(l, d), 'Oct 18');
    expect(fmtDow(l, d), 'Sun');
    expect(fmtDowNarrow(l, d), 'S');
    expect(fmtLong(l, d), 'Sunday, October 18');
    expect(fmtMonth(l, d), 'October 2026');
  });

  testWidgets('dates and times in Kannada', (tester) async {
    final c = await pumpWith(tester, false, 'kn');
    final d = DateTime(2026, 10, 18);
    expect(fmtDay(c.l10n, d), 'ಭಾನು, 18 ಅಕ್ಟೋ');
    expect(fmtMonth(c.l10n, d), 'ಅಕ್ಟೋಬರ್ 2026');
    // Kannada's own clock is 24-hour, like Flutter's Kannada time picker.
    expect(fmtClock(c, DateTime(2026, 1, 1, 23, 43)), '23:43');
    expect(fmtAxisHour(c, 9), '09');
  });
}
