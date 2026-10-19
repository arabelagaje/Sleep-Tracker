import 'package:flutter/material.dart';

import '../../../models/sleep_session.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/long_press_value.dart';

class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    super.key,
    required this.date,
    this.session,
    required this.level,
    required this.isToday,
    required this.isFuture,
    this.onTap,
  });

  final DateTime date;
  final SleepSession? session;
  final int level; // 0–4
  final bool isToday;
  final bool isFuture;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = session;
    final ink = switch (level) {
      0 => c.ink2,
      1 || 2 => c.heatInkLo,
      3 => c.heatInk3,
      _ => c.heatInkHi,
    };
    final cell = Container(
      decoration: BoxDecoration(
        color: c.heat[level],
        borderRadius: BorderRadius.circular(12),
        border: isToday ? Border.all(color: c.ink, width: 2) : null,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${date.day}',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink),
          ),
          if (s != null)
            Text(
              '${fmtHours(s.length)}h',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: ink.withValues(alpha: 0.85),
              ),
            ),
        ],
      ),
    );
    if (isFuture) return Opacity(opacity: 0.4, child: cell);
    return LongPressValue(
      valueText: s == null
          ? '${fmtDay(date)}: nothing logged'
          : '${fmtDur(s.length)}${s.quality == null ? '' : ' · ${s.quality}★'}',
      onTap: onTap,
      child: cell,
    );
  }
}
