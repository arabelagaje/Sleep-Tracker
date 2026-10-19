import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/sleep_session.dart';
import '../../providers/settings_provider.dart';
import '../../providers/sleep_provider.dart';
import '../../utils/sleep_stats.dart';
import '../../widgets/rate_prompt_dialog.dart';
import '../../widgets/session_editor_sheet.dart';
import '../../widgets/undo_snackbar.dart';
import 'widgets/bed_wake_cards.dart';
import 'widgets/last_night_card.dart';
import 'widgets/sleep_orb.dart';
import 'widgets/usual_bedtime_line.dart';
import 'widgets/week_bars_card.dart';

class TonightScreen extends StatelessWidget {
  const TonightScreen({super.key});

  Future<void> _toggle(BuildContext context) async {
    final sleep = context.read<SleepProvider>();
    if (!sleep.isSleeping) {
      await sleep.startSleep();
      return;
    }
    final done = await sleep.stopSleep();
    if (done == null || !context.mounted) return;
    if (context.read<SettingsProvider>().ratePrompt) {
      final q = await RatePromptDialog.show(context, done.length);
      if (q != null) await sleep.rate(done, q);
      if (!context.mounted) return;
    }
    UndoSnackbar.show(
      context,
      message: 'Session saved · tap it to rate or add notes',
      onUndo: () => sleep.resume(done),
    );
  }

  void _edit(BuildContext context, SleepSession s) => SessionEditorSheet.show(
    context,
    mode: s.isActive ? EditorMode.editActive : EditorMode.editNight,
    session: s,
  );

  @override
  Widget build(BuildContext context) {
    final sleep = context.watch<SleepProvider>();
    final goal = context.select<SettingsProvider, Duration>((s) => s.goal);
    final nights = sleep.nights;
    final last = sleep.lastNight;
    final active = sleep.active;
    final usual = usualTimes(nights);
    final today = dateOnly(DateTime.now());

    // Latest night per wake date wins (nights are newest first).
    final week = inLastDays(nights, today, 7);
    final days = List.generate(7, (i) {
      final d = addDays(today, i - 6);
      return (d, week.where((s) => s.nightDate == d).firstOrNull);
    });

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        SleepOrb(
          isSleeping: sleep.isSleeping,
          startedAt: active?.bedTime,
          onPressed: () => _toggle(context),
        ),
        UsualBedtimeLine(
          usualBedtime: usual?.bed,
          nightsUsed: usual?.nightsUsed ?? 0,
          isSleeping: sleep.isSleeping,
        ),
        const SizedBox(height: 16),
        BedWakeCards(
          bedTime: active?.bedTime ?? last?.bedTime,
          wakeTime: last?.wakeTime,
          isSleeping: sleep.isSleeping,
          onTap: () => _edit(context, active ?? last!),
        ),
        const SizedBox(height: 16),
        LastNightCard(
          session: last,
          deltaVsAverage: last != null && nights.length >= minNights
              ? last.length - averageDuration(nights)
              : null,
          onEdit: () => _edit(context, last!),
          onRate: (q) => sleep.rate(last!, q),
        ),
        const SizedBox(height: 16),
        WeekBarsCard(days: days, goal: goal, onTapSession: (s) => _edit(context, s)),
      ],
    );
  }
}
