import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/sleep_session.dart';
import '../../providers/settings_provider.dart';
import '../../providers/sleep_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../utils/sleep_stats.dart';
import '../../widgets/rate_prompt_dialog.dart';
import '../../widgets/session_context_menu.dart';
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

  // Long-press on the orb while sleeping: discard an accidental start.
  Future<void> _cancel(BuildContext context) async {
    final sleep = context.read<SleepProvider>();
    final active = sleep.active;
    if (active == null) return;
    HapticFeedback.mediumImpact();
    final c = context.colors;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Cancel this session?',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 19),
        ),
        content: Text(
          'Started at ${fmtClock(active.bedTime)} '
          '(${fmtDur(DateTime.now().difference(active.bedTime))} ago). '
          'It will be discarded, not saved as a night.',
          style: TextStyle(color: c.ink2, height: 1.45),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: c.danger),
            child: const Text('Discard'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: FilledButton.styleFrom(backgroundColor: c.accent, foregroundColor: c.onAccent),
            child: const Text('Keep sleeping'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await sleep.delete(active);
    if (!context.mounted) return;
    UndoSnackbar.show(context, message: 'Session cancelled', onUndo: () => sleep.restore(active));
  }

  void _menu(BuildContext context, SleepSession s, Offset pos) =>
      SessionContextMenu.show(context, position: pos, session: s);

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
          onLongPress: () => _cancel(context),
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
        WeekBarsCard(
          days: days,
          goal: goal,
          onTapSession: (s) => _edit(context, s),
          onLongPressSession: (s, pos) => _menu(context, s, pos),
          onLongPressEmptyDay: (date, pos) =>
              SessionContextMenu.showAddNight(context, position: pos, date: date),
        ),
      ],
    );
  }
}
