import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class OverflowMenu extends StatelessWidget {
  const OverflowMenu({super.key, required this.onSettings, required this.onAbout});

  final VoidCallback onSettings;
  final VoidCallback onAbout;

  // Opens the menu under the header's ⋮ button; it closes on outside tap.
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onSettings,
    required VoidCallback onAbout,
  }) => showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close menu',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 120),
    pageBuilder: (ctx, _, _) => SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 64, right: 14),
          child: OverflowMenu(
            onSettings: () {
              Navigator.pop(ctx);
              onSettings();
            },
            onAbout: () {
              Navigator.pop(ctx);
              onAbout();
            },
          ),
        ),
      ),
    ),
    transitionBuilder: (_, anim, _, child) => FadeTransition(opacity: anim, child: child),
  );

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget item(IconData icon, String label, VoidCallback onTap) => InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: SizedBox(
        height: 46,
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(icon, size: 18, color: c.ink2),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
    return Material(
      color: c.surface,
      elevation: 12,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: c.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: SizedBox(
          width: 190,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              item(Icons.settings_outlined, 'Settings', onSettings),
              item(Icons.info_outline, 'About', onAbout),
            ],
          ),
        ),
      ),
    );
  }
}
