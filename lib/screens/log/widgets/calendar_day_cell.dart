import 'package:flutter/material.dart';

import '../../../models/sleep_session.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/formatters.dart';

class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    super.key,
    required this.date,
    this.session,
    this.shade,
    required this.isToday,
    required this.isFuture,
    this.onTap,
    this.onLongPress,
  });

  final DateTime date;
  final SleepSession? session;
  final double? shade; // 0–1 (time ÷ goal, ½×…1½×); null = nothing logged
  final bool isToday;
  final bool isFuture;
  final VoidCallback? onTap;
  final ValueChanged<Offset>? onLongPress;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = session;
    final bg = shade == null ? c.heat[0] : c.heatAt(shade!);
    final ink = shade == null ? c.ink2 : c.inkOn(bg);
    final cell = Container(
      decoration: BoxDecoration(
        color: bg,
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPressStart: onLongPress == null ? null : (d) => onLongPress!(d.globalPosition),
      child: cell,
    );
  }
}
