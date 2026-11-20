import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/sleep_session.dart';
import '../../providers/settings_provider.dart';
import '../../providers/sleep_provider.dart';
import '../../utils/formatters.dart';
import '../../utils/sleep_stats.dart';
import '../../widgets/section_card.dart';
import '../../widgets/session_context_menu.dart';
import '../../widgets/session_editor_sheet.dart';
import '../../widgets/star_rating.dart';
import 'widgets/bed_wake_chart.dart';
import 'widgets/period_selector.dart';
import 'widgets/stat_tile.dart';
import 'widgets/summary_card.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  InsightsPeriod _period = InsightsPeriod.week;

  List<StatTileData> _tiles(List<SleepSession> list, List<SleepSession> prev, Duration goal) {
    final st = PeriodStats.of(list);
    if (st == null) return const [];
    final n = st.count, ok = n >= minNights;
    final l = context.l10n;
    final later = Text(l.afterNNights(minNights));

    Widget averageCaption() {
      if (!ok) return later;
      if (_period.days == null || prev.length < minNights) return Text(l.nNights(n));
      final d = st.average - averageDuration(prev);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(d.isNegative ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up, size: 14),
          Flexible(
            child: Text(
              l.vsPrevDays(fmtDur(l, d.abs()), _period.days!),
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    final q = st.avgQuality;
    return [
      StatTileData(l.statAverage, ok ? fmtDur(context.l10n, st.average) : '—', averageCaption()),
      StatTileData(
        l.metGoal,
        '${list.where((s) => s.length >= goal).length}/$n',
        Text(l.nightsAtLeast(fmtDur(l, goal))),
      ),
      StatTileData(
        l.statLongest,
        fmtDur(context.l10n, st.longest.length),
        Text(fmtDay(context.l10n, st.longest.nightDate)),
      ),
      StatTileData(
        l.statShortest,
        fmtDur(context.l10n, st.shortest.length),
        Text(fmtDay(context.l10n, st.shortest.nightDate)),
      ),
      StatTileData(
        l.statAvgBedtime,
        ok ? fmtTimeOfDay(context, st.avgBed) : '—',
        ok ? Text(l.spreadMinutes(st.bedSpreadMinutes)) : later,
      ),
      StatTileData(
        l.statAvgWake,
        ok ? fmtTimeOfDay(context, st.avgWake) : '—',
        ok ? Text(l.typicalMorning) : later,
      ),
      StatTileData(
        l.statAvgQuality,
        q == null ? '—' : l.qualityOutOf5(NumberFormat('0.0', l.localeName).format(q)),
        q == null ? Text(l.noRatingsYet) : StarRating(value: q.round(), size: 12),
      ),
      StatTileData(l.statNightsLogged, '$n', Text(l.nNotRatedYet(n - st.rated))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final nights = context.watch<SleepProvider>().nights;
    final goal = context.select<SettingsProvider, Duration>((s) => s.goal);
    final today = dateOnly(DateTime.now());
    final days = _period.days;

    final list = days == null ? nights : inLastDays(nights, today, days);
    final prev = days == null ? <SleepSession>[] : inLastDays(nights, today, days, offset: days);
    final l = context.l10n;
    final rangeLabel = days == null
        ? (list.isEmpty ? '' : l.sinceDate(fmtDay(l, list.last.nightDate)))
        : l.dateRange(fmtDay(l, addDays(today, 1 - days)), fmtDay(l, today));

    final recent = nights.take(usualWindow).toList().reversed.toList();
    final usual = usualTimes(nights);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        SummaryCard(
          period: _period,
          onPeriodChanged: (p) => setState(() => _period = p),
          rangeLabel: rangeLabel,
          tiles: _tiles(list, prev, goal),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: context.l10n.bedWakeTimes,
          trailing: recent.isEmpty ? null : CardCaption(l.lastNNights(recent.length)),
          child: BedWakeChart(
            sessions: recent,
            usualBedtime: usual?.bed,
            usualWake: usual?.wake,
            goal: goal,
            onLongPressSession: (s, pos) =>
                SessionContextMenu.show(context, position: pos, session: s),
            onTapSession: (s) =>
                SessionEditorSheet.show(context, mode: EditorMode.editNight, session: s),
          ),
        ),
      ],
    );
  }
}
