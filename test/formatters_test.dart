import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_tracker/utils/formatters.dart';

void main() {
  Future<BuildContext> pumpWith24h(WidgetTester tester, bool use24h) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(alwaysUse24HourFormat: use24h),
        child: Builder(
          builder: (c) {
            ctx = c;
            return const SizedBox();
          },
        ),
      ),
    );
    return ctx;
  }

  testWidgets('12-hour phone', (tester) async {
    final c = await pumpWith24h(tester, false);
    expect(fmtClock(c, DateTime(2026, 1, 1, 23, 43)), '11:43 PM');
    expect(fmtTimeOfDay(c, const TimeOfDay(hour: 7, minute: 5)), '7:05 AM');
    expect([18, 0, 9, 12].map((h) => fmtAxisHour(c, h)), ['6p', '12a', '9a', '12p']);
  });

  testWidgets('24-hour phone', (tester) async {
    final c = await pumpWith24h(tester, true);
    expect(fmtClock(c, DateTime(2026, 1, 1, 23, 43)), '23:43');
    expect(fmtTimeOfDay(c, const TimeOfDay(hour: 7, minute: 5)), '07:05');
    expect([18, 0, 9, 12].map((h) => fmtAxisHour(c, h)), ['18', '00', '09', '12']);
  });
}
