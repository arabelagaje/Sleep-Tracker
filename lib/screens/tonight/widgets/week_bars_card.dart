import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../../models/sleep_session.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/formatters.dart';
import '../../../utils/sleep_stats.dart';
import '../../../widgets/session_context_menu.dart';
import '../../../widgets/section_card.dart';

class WeekBarsCard extends StatelessWidget {
  const WeekBarsCard({
    super.key,
    required this.days,
    required this.goal,
    required this.onTapSession,
    required this.onLongPressSession,
    required this.onLongPressEmptyDay,
  });

  final List<(DateTime, SleepSession?)> days; // 7 entries, oldest to today
  final Duration goal;
  final ValueChanged<SleepSession> onTapSession;
  final SessionLongPress onLongPressSession;
  final void Function(DateTime date, Offset position) onLongPressEmptyDay;

  static const _barArea = 90.0, _labelArea = 24.0;

  List<SleepSession> get _logged => days.map((d) => d.$2).whereType<SleepSession>().toList();

  String _summary(AppLocalizations l) {
    final logged = _logged;
    if (logged.isEmpty) return l.noNightsYet;
    if (logged.length < minNights) return l.nOf7NightsLogged(logged.length);
    final met = logged.where((s) => s.length >= goal).length;
    return l.weekSummary(fmtDur(l, averageDuration(logged)), met, logged.length);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Scale to the longer of 10h, the goal and the longest night so nothing clips.
    var maxMin = 600;
    for (final (_, s) in days) {
      if (s != null && s.length.inMinutes > maxMin) maxMin = s.length.inMinutes;
    }
    if (goal.inMinutes > maxMin) maxMin = goal.inMinutes;
    double h(Duration d) => _barArea * d.inMinutes / maxMin;
    final logged = _logged;

    final bars = SizedBox(
      height: _barArea + _labelArea + 6,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: _labelArea + h(goal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  context.l10n.goalDuration(fmtDur(context.l10n, goal)),
                  style: TextStyle(fontSize: 11, color: c.ink2),
                ),
                const SizedBox(height: 2),
                Opacity(opacity: 0.45, child: _DashedLine(color: c.ink2)),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final (date, s) in days)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: s == null ? null : () => onTapSession(s),
                      onLongPressStart: (d) => s == null
                          ? onLongPressEmptyDay(date, d.globalPosition)
                          : onLongPressSession(s, d.globalPosition),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            constraints: const BoxConstraints(maxWidth: 26),
                            height: s == null ? 4 : h(s.length).clamp(4, _barArea + 6),
                            decoration: BoxDecoration(
                              color: s == null
                                  ? c.track
                                  : c.accent.withValues(alpha: s.length >= goal ? 1 : 0.45),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                                bottom: Radius.circular(4),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: _labelArea,
                            child: Center(
                              child: Text(
                                fmtDowNarrow(context.l10n, date),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: c.ink2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    return SectionCard(
      title: context.l10n.thisWeek,
      trailing: CardCaption(_summary(context.l10n)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bars,
          if (logged.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              context.l10n.sleepDebtLine(fmtDur(context.l10n, sleepDebt(logged, goal))),
              style: TextStyle(fontSize: 14, color: c.ink2),
            ),
          ],
        ],
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(double.infinity, 1.5), painter: _DashPainter(color));
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = size.height;
    for (double x = 0; x < size.width; x += 8) {
      canvas.drawLine(Offset(x, 0), Offset(x + 4, 0), p);
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}
