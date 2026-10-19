import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../shell/sub_screen.dart';
import 'widgets/settings_group.dart';
import 'widgets/settings_switch_tile.dart';
import 'widgets/sleep_goal_stepper.dart';
import 'widgets/theme_mode_selector.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
      ],
    );
  }
}
