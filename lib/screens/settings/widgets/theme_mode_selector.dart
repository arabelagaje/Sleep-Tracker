import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../../widgets/segmented_control.dart';

class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({super.key, required this.value, required this.onChanged});

  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedControl<ThemeMode>(
    options: [
      (ThemeMode.system, context.l10n.themeSystem),
      (ThemeMode.light, context.l10n.themeLight),
      (ThemeMode.dark, context.l10n.themeDark),
    ],
    value: value,
    onChanged: onChanged,
  );
}
