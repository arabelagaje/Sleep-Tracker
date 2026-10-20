import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../utils/sleep_stats.dart';

// One night on a 6pm → 12pm track.
class TimelineLane extends StatelessWidget {
  const TimelineLane({
    super.key,
    required this.bedTime,
    required this.wakeTime,
    required this.underGoal,
    required this.hasNote,
  });

  final DateTime bedTime;
  final DateTime wakeTime;
  final bool underGoal;
  final bool hasNote;

  static const _span = 18 * 60;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final start = (eveMin(bedTime) / _span).clamp(0.0, 1.0);
    // Wake measured from bed so nights longer than the track still end at the edge.
    final end = ((eveMin(bedTime) + wakeTime.difference(bedTime).inMinutes) / _span).clamp(
      start,
      1.0,
    );
    return Container(
      height: 26,
      decoration: BoxDecoration(color: c.track, borderRadius: BorderRadius.circular(8)),
      child: LayoutBuilder(
        builder: (context, box) => Stack(
          children: [
            Positioned(
              left: box.maxWidth / 3,
              top: 0,
              bottom: 0,
              child: Container(width: 1, color: c.ink2.withValues(alpha: 0.25)),
            ),
            Positioned(
              left: box.maxWidth * start,
              width: box.maxWidth * (end - start),
              top: 5,
              bottom: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: c.accent.withValues(alpha: underGoal ? 0.5 : 1),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            if (hasNote)
              Positioned(
                right: 4,
                top: 0,
                bottom: 0,
                child: Icon(Icons.sticky_note_2_outlined, size: 12, color: c.ink2),
              ),
          ],
        ),
      ),
    );
  }
}
