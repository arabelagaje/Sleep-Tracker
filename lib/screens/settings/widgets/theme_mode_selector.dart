import 'package:flutter/material.dart';

import '../../../widgets/segmented_control.dart';

class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({super.key, required this.value, required this.onChanged});

  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedControl<ThemeMode>(
    options: const [
      (ThemeMode.system, 'System'),
      (ThemeMode.light, 'Light'),
      (ThemeMode.dark, 'Dark'),
    ],
    value: value,
    onChanged: onChanged,
  );
}
