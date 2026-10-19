import 'package:flutter/material.dart';

import '../../../models/sleep_session.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/star_rating.dart';
import 'timeline_axis.dart';
import 'timeline_lane.dart';

class TimelineRow extends StatelessWidget {
  const TimelineRow({
    super.key,
    required this.session,
    required this.goal,
    required this.onTap,
    required this.onRate,
  });

  final SleepSession session;
  final Duration goal;
  final VoidCallback onTap;
  final ValueChanged<int?> onRate;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = session;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: c.line)),
        ),
        child: Row(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints.tightFor(
                width: timelineDayWidth,
              ).copyWith(minHeight: 44),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    fmtDow(s.nightDate),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    fmtMonthDay(s.nightDate),
                    style: TextStyle(fontSize: 11.5, color: c.ink2, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(width: timelineGap),
            Expanded(
              child: TimelineLane(
                bedTime: s.bedTime,
                wakeTime: s.wakeTime!,
                underGoal: s.length < goal,
                hasNote: s.hasNotes,
                valueText: '${fmtClock(s.bedTime)} → ${fmtClock(s.wakeTime!)}',
              ),
            ),
            const SizedBox(width: timelineGap),
            SizedBox(
              width: timelineValueWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    fmtDur(s.length),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  StarRating(value: s.quality, onChanged: onRate, size: 13, gap: 0.5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
