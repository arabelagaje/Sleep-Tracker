import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/sleep_session.dart';
import '../../providers/settings_provider.dart';
import '../../providers/sleep_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/sleep_stats.dart';
import '../../widgets/empty_note.dart';
import '../../widgets/session_context_menu.dart';
import '../../widgets/session_editor_sheet.dart';
import 'widgets/calendar_legend.dart';
import 'widgets/log_filter_chips.dart';
import 'widgets/log_view_toggle.dart';
import 'widgets/month_calendar.dart';
import 'widgets/timeline_axis.dart';
import 'widgets/timeline_row.dart';
import 'widgets/week_group_header.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  LogView _view = LogView.timeline;
  LogFilter _filter = LogFilter.all;
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  void _edit(SleepSession s) =>
      SessionEditorSheet.show(context, mode: EditorMode.editNight, session: s);

  void _add([DateTime? day]) =>
      SessionEditorSheet.show(context, mode: EditorMode.create, initialDate: day);

  bool _matches(SleepSession s, Duration goal) => switch (_filter) {
    LogFilter.all => true,
    LogFilter.unrated => s.quality == null,
    LogFilter.withNotes => s.hasNotes,
    LogFilter.underGoal => !s.isNap && s.length < goal,
  };

  String _weekLabel(DateTime start, DateTime thisWeek) {
    final ago = thisWeek.difference(start).inDays ~/ 7;
    return switch (ago) {
      0 => 'This week',
      1 => 'Last week',
      _ => '$ago weeks ago',
    };
  }

  // [sessions] includes naps; week averages use nights only.
  List<Widget> _timeline(List<SleepSession> sessions, Duration goal) {
    final sleep = context.read<SleepProvider>();
    if (sessions.isEmpty) {
      return const [
        EmptyNote(message: 'No nights yet. Tap the moon at bedtime, or add a past night below.'),
      ];
    }
    // Week averages always cover the whole week, whatever the filter.
    final byWeek = <DateTime, List<SleepSession>>{};
    for (final s in sessions.where((s) => !s.isNap)) {
      byWeek.putIfAbsent(weekStart(s.nightDate), () => []).add(s);
    }
    final thisWeek = weekStart(DateTime.now());
    final out = <Widget>[];
    DateTime? current;
    for (final s in sessions.where((s) => _matches(s, goal))) {
      final wk = weekStart(s.nightDate);
      if (wk != current) {
        current = wk;
        final all = byWeek[wk] ?? const <SleepSession>[];
        out.add(
          WeekGroupHeader(
            label: _weekLabel(wk, thisWeek),
            average: all.length >= minNights ? averageDuration(all) : null,
          ),
        );
      }
      out.add(
        TimelineRow(
          session: s,
          goal: goal,
          onTap: () => _edit(s),
          onRate: (q) => sleep.rate(s, q),
          onLongPress: (pos) => SessionContextMenu.show(context, position: pos, session: s),
        ),
      );
    }
    if (out.isEmpty) return const [EmptyNote(message: 'No nights match this filter.')];
    return [const TimelineAxis(), ...out];
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final sleep = context.watch<SleepProvider>();
    final nights = sleep.nights;
    final goal = context.select<SettingsProvider, Duration>((s) => s.goal);
    final today = dateOnly(DateTime.now());
    final thisMonth = DateTime(today.year, today.month);

    final Widget body;
    if (_view == LogView.timeline) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LogFilterChips(value: _filter, onChanged: (f) => setState(() => _filter = f)),
          const SizedBox(height: 12),
          ..._timeline(sleep.finished, goal),
          const SizedBox(height: 12),
          _TimelineLegend(colors: c),
        ],
      );
    } else {
      // Nights are newest first, so iterating in reverse lets the latest per date win.
      final byDate = <DateTime, SleepSession>{for (final s in nights.reversed) s.nightDate: s};
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MonthCalendar(
            month: _month,
            sessionsByDate: byDate,
            today: today,
            goal: goal,
            onTapSession: _edit,
            onLongPressSession: (s, pos) =>
                SessionContextMenu.show(context, position: pos, session: s),
            onTapEmptyDay: _add,
            onLongPressEmptyDay: (date, pos) =>
                SessionContextMenu.showAddNight(context, position: pos, date: date),
            onPrevMonth: () => setState(() => _month = DateTime(_month.year, _month.month - 1)),
            onNextMonth: _month == thisMonth
                ? null
                : () => setState(() => _month = DateTime(_month.year, _month.month + 1)),
          ),
          const SizedBox(height: 12),
          const CalendarLegend(),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        LogViewToggle(value: _view, onChanged: (v) => setState(() => _view = v)),
        const SizedBox(height: 16),
        body,
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _add,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            foregroundColor: c.accentInk,
            side: BorderSide(color: c.line, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add a past night'),
        ),
      ],
    );
  }
}

class _TimelineLegend extends StatelessWidget {
  const _TimelineLegend({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: 12, color: colors.ink2);
    Widget swatch(double alpha) => Container(
      width: 12,
      height: 8,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: alpha),
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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sticky_note_2_outlined, size: 12, color: colors.ink2),
            const SizedBox(width: 4),
            Text('Has note', style: style),
          ],
        ),
      ],
    );
  }
}
