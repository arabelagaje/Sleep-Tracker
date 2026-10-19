import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/sleep_session.dart';
import '../../providers/settings_provider.dart';
import '../../providers/sleep_provider.dart';
import '../../utils/formatters.dart';
import '../../utils/sleep_stats.dart';
import '../../widgets/section_card.dart';
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
    const later = Text('after $minNights nights');

    Widget averageCaption() {
      if (!ok) return later;
      if (_period.days == null || prev.length < minNights) return Text('$n nights');
      final d = st.average - averageDuration(prev);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(d.isNegative ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up, size: 14),
          Flexible(
            child: Text(
              '${fmtDur(d.abs())} vs prev. ${_period.days}d',
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    final q = st.avgQuality;
    return [
      StatTileData('Average', ok ? fmtDur(st.average) : '—', averageCaption()),
      StatTileData(
        'Met goal',
        '${list.where((s) => s.length >= goal).length}/$n',
        Text('nights ≥ ${fmtDur(goal)}'),
      ),
      StatTileData('Longest', fmtDur(st.longest.length), Text(fmtDay(st.longest.nightDate))),
      StatTileData('Shortest', fmtDur(st.shortest.length), Text(fmtDay(st.shortest.nightDate))),
      StatTileData(
        'Avg bedtime',
        ok ? fmtTimeOfDay(st.avgBed) : '—',
        ok ? Text('± ${st.bedSpreadMinutes} min') : later,
      ),
      StatTileData(
        'Avg wake',
        ok ? fmtTimeOfDay(st.avgWake) : '—',
        ok ? const Text('typical morning') : later,
      ),
      StatTileData(
        'Avg quality',
        q == null ? '—' : '${q.toStringAsFixed(1)} / 5',
        q == null ? const Text('no ratings yet') : StarRating(value: q.round(), size: 12),
      ),
      StatTileData('Nights logged', '$n', Text('${n - st.rated} not rated yet')),
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
    final rangeLabel = days == null
        ? (list.isEmpty ? '' : 'since ${fmtDay(list.last.nightDate)}')
        : '${fmtDay(addDays(today, 1 - days))} – ${fmtDay(today)}';

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
          title: 'Bed & wake times',
          trailing: recent.isEmpty
              ? null
              : CardCaption('last ${recent.length} night${recent.length == 1 ? '' : 's'}'),
          child: BedWakeChart(
            sessions: recent,
            usualBedtime: usual?.bed,
            usualWake: usual?.wake,
            goal: goal,
            onTapSession: (s) =>
                SessionEditorSheet.show(context, mode: EditorMode.editNight, session: s),
          ),
        ),
      ],
    );
  }
}
