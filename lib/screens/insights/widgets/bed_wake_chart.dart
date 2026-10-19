import 'package:flutter/material.dart';

import '../../../models/sleep_session.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/formatters.dart';
import '../../../utils/sleep_stats.dart';
import '../../../widgets/empty_note.dart';
import '../../../widgets/long_press_value.dart';

class BedWakeChart extends StatelessWidget {
  const BedWakeChart({
    super.key,
    required this.sessions,
    this.usualBedtime,
    this.usualWake,
    required this.goal,
    required this.onTapSession,
  });

  final List<SleepSession> sessions; // up to 14, oldest to newest
  final TimeOfDay? usualBedtime;
  final TimeOfDay? usualWake;
  final Duration goal;
  final ValueChanged<SleepSession> onTapSession;

  static const _height = 180.0, _left = 34.0, _top = 8.0, _bottom = 16.0;
  static const _y0 = 2 * 60, _y1 = 16 * 60; // 8pm → 10am, in minutes after 6pm

  static double _y(num m) =>
      _top + ((m.clamp(_y0, _y1) - _y0) / (_y1 - _y0)) * (_height - _top - _bottom);

  static int _todEve(TimeOfDay t) => ((t.hour + 6) % 24) * 60 + t.minute;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (sessions.length < minNights) {
      return const EmptyNote(
        message: 'Your bed and wake pattern shows up after $minNights nights.',
      );
    }
    final n = sessions.length;
    final axis = TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: c.ink2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _height,
          child: LayoutBuilder(
            builder: (context, box) {
              // Always 14 slots so bars keep their width while history fills in (newest right).
              final bw = (box.maxWidth - _left) / usualWindow;
              final x0 = _left + (usualWindow - n) * bw;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _GridPainter(
                        line: c.line,
                        dash: c.ink2,
                        usual: [
                          if (usualBedtime != null) _y(_todEve(usualBedtime!)),
                          if (usualWake != null) _y(_todEve(usualWake!)),
                        ],
                      ),
                    ),
                  ),
                  for (final (m, t) in [
                    (2 * 60, '8p'),
                    (6 * 60, '12a'),
                    (10 * 60, '4a'),
                    (14 * 60, '8a'),
                  ])
                    Positioned(
                      left: 0,
                      width: _left - 6,
                      top: _y(m) - 7,
                      child: Text(t, style: axis, textAlign: TextAlign.right),
                    ),
                  for (var i = 0; i < n; i++) _bar(sessions[i], x0 + i * bw, bw, c),
                  Positioned(
                    left: x0,
                    bottom: -2,
                    child: Text(fmtDay(sessions.first.nightDate), style: axis),
                  ),
                  Positioned(right: 0, bottom: -2, child: Text('Latest', style: axis)),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        _legend(c),
      ],
    );
  }

  Widget _bar(SleepSession s, double x, double bw, AppColors c) {
    final start = eveMin(s.bedTime);
    final top = _y(start), bottom = _y(start + s.length.inMinutes);
    return Positioned(
      left: x + bw * 0.2,
      width: bw * 0.6,
      top: top,
      height: (bottom - top).clamp(2, _height),
      child: LongPressValue(
        valueText:
            '${fmtDay(s.nightDate)}: ${fmtClock(s.bedTime)} → ${fmtClock(s.wakeTime!)} (${fmtDur(s.length)})',
        onTap: () => onTapSession(s),
        child: Container(
          decoration: BoxDecoration(
            color: c.accent.withValues(alpha: s.length >= goal ? 1 : 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _legend(AppColors c) {
    final style = TextStyle(fontSize: 12, color: c.ink2);
    Widget swatch(double alpha) => Container(
      width: 12,
      height: 8,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        color: c.accent.withValues(alpha: alpha),
        borderRadius: BorderRadius.circular(3),
      ),
    );
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            swatch(1),
            Text('Met goal', style: style),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            swatch(0.5),
            Text('Under goal', style: style),
          ],
        ),
        if (usualBedtime != null && usualWake != null)
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: '- - Average '),
                TextSpan(
                  text: '${fmtTimeOfDay(usualBedtime!)} → ${fmtTimeOfDay(usualWake!)}',
                  style: TextStyle(color: c.ink, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            style: style,
          ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.line, required this.dash, required this.usual});

  final Color line;
  final Color dash;
  final List<double> usual;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..color = line;
    for (final m in [2 * 60, 6 * 60, 10 * 60, 14 * 60]) {
      final y = BedWakeChart._y(m);
      canvas.drawLine(Offset(BedWakeChart._left, y), Offset(size.width, y), grid);
    }
    final d = Paint()
      ..color = dash
      ..strokeWidth = 1.5;
    for (final y in usual) {
      for (double x = BedWakeChart._left; x < size.width; x += 8) {
        canvas.drawLine(Offset(x, y), Offset(x + 4, y), d);
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) =>
      old.line != line || old.dash != dash || old.usual.toString() != usual.toString();
}
