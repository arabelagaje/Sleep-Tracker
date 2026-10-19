import 'package:flutter/material.dart';

import '../../../widgets/segmented_control.dart';

enum InsightsPeriod {
  week(7, '7 days'),
  month(30, '30 days'),
  all(null, 'All time');

  const InsightsPeriod(this.days, this.label);

  final int? days; // null = all time
  final String label;
}

class PeriodSelector extends StatelessWidget {
  const PeriodSelector({super.key, required this.value, required this.onChanged});

  final InsightsPeriod value;
  final ValueChanged<InsightsPeriod> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedControl<InsightsPeriod>(
    options: [for (final p in InsightsPeriod.values) (p, p.label)],
    value: value,
    onChanged: onChanged,
  );
}
