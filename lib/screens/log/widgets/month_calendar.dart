import 'package:flutter/material.dart';

import '../../../models/sleep_session.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/formatters.dart';
import '../../../utils/sleep_stats.dart';
import 'calendar_day_cell.dart';

class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.month,
    required this.sessionsByDate,
    required this.today,
    required this.goal,
    required this.onTapSession,
    required this.onTapEmptyDay,
    required this.onPrevMonth,
    this.onNextMonth,
  });

  final DateTime month;
  final Map<DateTime, SleepSession> sessionsByDate;
  final DateTime today;
  final Duration goal;
  final ValueChanged<SleepSession> onTapSession;
  final ValueChanged<DateTime> onTapEmptyDay;
  final VoidCallback onPrevMonth;
  final VoidCallback? onNextMonth; // null = disabled

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final first = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final lead = first.weekday - 1; // Monday first
    final cells = <Widget>[
      for (final d in ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
        Center(
          child: Text(
            d,
            style: TextStyle(fontSize: 11, color: c.ink2, fontWeight: FontWeight.w700),
          ),
        ),
      for (var i = 0; i < lead; i++) const SizedBox(),
      for (var day = 1; day <= daysInMonth; day++) _cell(DateTime(month.year, month.month, day)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                fmtMonth(month),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              tooltip: 'Previous month',
              icon: Icon(Icons.chevron_left, color: c.ink2),
              onPressed: onPrevMonth,
            ),
            IconButton(
              tooltip: 'Next month',
              icon: Icon(Icons.chevron_right, color: onNextMonth == null ? c.muted : c.ink2),
              onPressed: onNextMonth,
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 7,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: cells,
        ),
      ],
    );
  }

  Widget _cell(DateTime date) {
    final s = sessionsByDate[date];
    final isFuture = date.isAfter(today);
    return CalendarDayCell(
      date: date,
      session: s,
      level: s == null ? 0 : sleepLevel(s.length, goal),
      isToday: date == today,
      isFuture: isFuture,
      onTap: isFuture ? null : (s == null ? () => onTapEmptyDay(date) : () => onTapSession(s)),
    );
  }
}
