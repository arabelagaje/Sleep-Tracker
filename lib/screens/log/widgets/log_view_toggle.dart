import 'package:flutter/material.dart';

import '../../../widgets/segmented_control.dart';

enum LogView { timeline, month }

class LogViewToggle extends StatelessWidget {
  const LogViewToggle({super.key, required this.value, required this.onChanged});

  final LogView value;
  final ValueChanged<LogView> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedControl<LogView>(
    options: const [(LogView.timeline, 'Timeline'), (LogView.month, 'Month')],
    value: value,
    onChanged: onChanged,
  );
}
