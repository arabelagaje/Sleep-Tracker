import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../providers/settings_provider.dart';
import '../../providers/sleep_provider.dart';
import '../../services/backup.dart';
import '../../services/database_helper.dart';
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
        UndoSnackbar.show(context, message: context.l10n.backupSaved);
      }
    } catch (_) {
      if (context.mounted) UndoSnackbar.show(context, message: context.l10n.backupSaveFailed);
    }
  }

  Future<void> _import(BuildContext context) async {
    final c = context.colors;
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          l.replaceAllDataTitle,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 19),
        ),
        content: Text(l.replaceAllDataBody, style: TextStyle(color: c.ink2, height: 1.45)),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: c.accent, foregroundColor: c.onAccent),
            child: Text(l.chooseFile),
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
      message = l.backupRestored;
    } on NewerBackupException {
      message = l.backupTooNew;
    } on FormatException {
      message = l.notABackup;
    } catch (_) {
      message = l.backupRestoreFailed;
    }
    if (context.mounted) UndoSnackbar.show(context, message: message);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    final l = context.l10n;
    return SubScreen(
      title: l.settings,
      children: [
        SettingsGroup(
          title: l.settingsGroupSleep,
          children: [
            SettingsRow(
              title: l.sleepGoal,
              subtitle: l.sleepGoalSubtitle,
              trailing: SleepGoalStepper(
                value: s.goal,
                onChanged: s.setGoal,
                min: SettingsProvider.minGoal,
                max: SettingsProvider.maxGoal,
                step: SettingsProvider.goalStep,
              ),
            ),
            SettingsSwitchTile(
              title: l.ratePromptSetting,
              subtitle: l.ratePromptSettingSubtitle,
              value: s.ratePrompt,
              onChanged: s.setRatePrompt,
            ),
          ],
        ),
        const SizedBox(height: 16),
        SettingsGroup(
          title: l.settingsGroupAppearance,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SettingsRow(title: l.theme),
                  ThemeModeSelector(value: s.themeMode, onChanged: s.setThemeMode),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SettingsGroup(
          title: l.settingsGroupData,
          children: [
            SettingsActionTile(
              title: l.exportData,
              subtitle: l.exportDataSubtitle,
              actionLabel: l.exportAction,
              onPressed: () => _export(context),
            ),
            SettingsActionTile(
              title: l.importData,
              subtitle: l.importDataSubtitle,
              actionLabel: l.importAction,
              onPressed: () => _import(context),
            ),
          ],
        ),
      ],
    );
  }
}
