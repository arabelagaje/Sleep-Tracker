import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../providers/sleep_provider.dart';
import '../../services/backup.dart';
import '../../theme/app_theme.dart';
import '../../widgets/undo_snackbar.dart';
import '../shell/sub_screen.dart';
import 'widgets/settings_action_tile.dart';
import 'widgets/settings_group.dart';
import 'widgets/settings_switch_tile.dart';
import 'widgets/sleep_goal_stepper.dart';
import 'widgets/theme_mode_selector.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _export(BuildContext context) async {
    try {
      if (await Backup.export() && context.mounted) {
        UndoSnackbar.show(context, message: 'Backup saved');
      }
    } catch (_) {
      if (context.mounted) UndoSnackbar.show(context, message: 'Couldn’t save the backup');
    }
  }

  Future<void> _import(BuildContext context) async {
    final c = context.colors;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Replace all data?',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 19),
        ),
        content: Text(
          'Your sessions and settings will be replaced by the ones in the backup file.',
          style: TextStyle(color: c.ink2, height: 1.45),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: c.accent, foregroundColor: c.onAccent),
            child: const Text('Choose file'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    final sleep = context.read<SleepProvider>();
    final settings = context.read<SettingsProvider>();
    String message;
    try {
      final path = await Backup.pick();
      if (path == null) return;
      await Backup.restore(path);
      await sleep.load();
      await settings.load();
      message = 'Backup restored';
    } on FormatException catch (e) {
      message = e.message;
    } catch (_) {
      message = 'Couldn’t restore the backup';
    }
    if (context.mounted) UndoSnackbar.show(context, message: message);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    return SubScreen(
      title: 'Settings',
      children: [
        SettingsGroup(
          title: 'Sleep',
          children: [
            SettingsRow(
              title: 'Sleep goal',
              subtitle: 'Drives the goal line and “met goal” stats',
              trailing: SleepGoalStepper(
                value: s.goal,
                onChanged: s.setGoal,
                min: SettingsProvider.minGoal,
                max: SettingsProvider.maxGoal,
                step: SettingsProvider.goalStep,
              ),
            ),
            SettingsSwitchTile(
              title: 'Ask me to rate in the morning',
              subtitle: 'A gentle prompt after you stop — never required',
              value: s.ratePrompt,
              onChanged: s.setRatePrompt,
            ),
          ],
        ),
        const SizedBox(height: 16),
        SettingsGroup(
          title: 'Appearance',
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SettingsRow(title: 'Theme'),
                  ThemeModeSelector(value: s.themeMode, onChanged: s.setThemeMode),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SettingsGroup(
          title: 'Data',
          children: [
            SettingsActionTile(
              title: 'Export data',
              subtitle: 'Save a backup file of everything',
              actionLabel: 'Export',
              onPressed: () => _export(context),
            ),
            SettingsActionTile(
              title: 'Import data',
              subtitle: 'Replace everything with a backup file',
              actionLabel: 'Import',
              onPressed: () => _import(context),
            ),
          ],
        ),
      ],
    );
  }
}
