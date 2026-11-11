import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../theme/app_theme.dart';
import '../../widgets/undo_snackbar.dart';
import '../settings/widgets/settings_action_tile.dart';
import '../settings/widgets/settings_group.dart';
import '../shell/sub_screen.dart';

const appVersion = '1.2.0'; // keep in sync with pubspec.yaml

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    return SubScreen(
      title: l.about,
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
        Text(
          l.appName,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        Text(
          'Version $appVersion',
          textAlign: TextAlign.center,
          style: TextStyle(color: c.ink2, fontSize: 13),
        ),
        const SizedBox(height: 16),
        Text(
          l.aboutBlurb,
          textAlign: TextAlign.center,
          style: TextStyle(color: c.ink2, fontSize: 14, height: 1.55),
        ),
        const SizedBox(height: 16),
        SettingsGroup(
          title: l.aboutGroupApp,
          children: [
            SettingsRow(title: l.yourData, subtitle: l.yourDataSubtitle),
            SettingsActionTile(
              title: l.sendFeedback,
              subtitle: l.sendFeedbackSubtitle,
              actionLabel: l.send,
              onPressed: () => UndoSnackbar.show(context, message: l.feedbackComingSoon),
            ),
            SettingsActionTile(
              title: l.licenses,
              subtitle: l.licensesSubtitle,
              actionLabel: l.view,
              onPressed: () => showLicensePage(
                context: context,
                applicationName: l.appName,
                applicationVersion: appVersion,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
