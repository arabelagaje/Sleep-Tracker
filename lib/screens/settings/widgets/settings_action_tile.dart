import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import 'settings_group.dart';

class SettingsActionTile extends StatelessWidget {
  const SettingsActionTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.actionLabel,
    required this.onPressed,
    this.busy = false,
  });

  final String title;
  final String? subtitle;
  final String actionLabel;
  final VoidCallback onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SettingsRow(
      title: title,
      subtitle: subtitle,
      trailing: OutlinedButton(
        onPressed: busy ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 38),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          backgroundColor: c.surface2,
          foregroundColor: c.accentInk,
          side: BorderSide(color: c.line),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        child: busy
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(actionLabel),
      ),
    );
  }
}
