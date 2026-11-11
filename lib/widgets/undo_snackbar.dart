import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

// Floating toast with an Undo action ("Session saved", "Session deleted").
class UndoSnackbar {
  static void show(BuildContext context, {required String message, VoidCallback? onUndo}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 3800),
          action: onUndo == null
              ? null
              : SnackBarAction(label: context.l10n.undo, onPressed: onUndo),
        ),
      );
  }
}
