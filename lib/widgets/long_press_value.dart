import 'package:flutter/material.dart';

import 'undo_snackbar.dart';

// Long-press shows the value as a toast; a normal tap still does [onTap].
class LongPressValue extends StatelessWidget {
  const LongPressValue({super.key, required this.valueText, this.onTap, required this.child});

  final String valueText;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    label: valueText,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: () => UndoSnackbar.show(context, message: valueText),
      child: child,
    ),
  );
}
