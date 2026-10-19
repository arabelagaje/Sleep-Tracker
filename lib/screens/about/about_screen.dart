import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/undo_snackbar.dart';
import '../settings/widgets/settings_action_tile.dart';
import '../settings/widgets/settings_group.dart';
import '../shell/sub_screen.dart';

const appVersion = '1.0.0'; // keep in sync with pubspec.yaml

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SubScreen(
      title: 'About',
      children: [
        const SizedBox(height: 14),
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: RadialGradient(
                center: const Alignment(-0.36, -0.44),
                colors: [c.orbA, c.orbB],
                stops: const [0, 0.7],
              ),
            ),
            child: const Icon(Icons.bedtime_outlined, size: 34, color: Colors.white),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Sleep Tracker',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        Text(
          'Version $appVersion',
          textAlign: TextAlign.center,
          style: TextStyle(color: c.ink2, fontSize: 13),
        ),
        const SizedBox(height: 16),
        Text(
          'Tap to log bed and wake times, rate your nights and keep notes. '
          'Everything stays on this device.',
          textAlign: TextAlign.center,
          style: TextStyle(color: c.ink2, fontSize: 14, height: 1.55),
        ),
        const SizedBox(height: 16),
        SettingsGroup(
          title: 'App',
          children: [
            const SettingsRow(
              title: 'Your data',
              subtitle: 'Stored locally in SQLite, never uploaded',
            ),
            SettingsActionTile(
              title: 'Send feedback',
              subtitle: 'Ideas, bugs, anything',
              actionLabel: 'Send',
              onPressed: () =>
                  UndoSnackbar.show(context, message: 'Sending feedback is coming soon'),
            ),
            SettingsActionTile(
              title: 'Open-source licenses',
              subtitle: 'Packages this app is built with',
              actionLabel: 'View',
              onPressed: () => showLicensePage(
                context: context,
                applicationName: 'Sleep Tracker',
                applicationVersion: appVersion,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
