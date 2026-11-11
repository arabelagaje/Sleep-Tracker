import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../../widgets/segmented_control.dart';

enum InsightsPeriod {
  week(7),
  month(30),
  all(null);

  const InsightsPeriod(this.days);

  final int? days; // null = all time

  String label(AppLocalizations l) => switch (this) {
    week => l.period7Days,
    month => l.period30Days,
    all => l.periodAllTime,
  };
}

class PeriodSelector extends StatelessWidget {
  const PeriodSelector({super.key, required this.value, required this.onChanged});

  final InsightsPeriod value;
  final ValueChanged<InsightsPeriod> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedControl<InsightsPeriod>(
    options: [for (final p in InsightsPeriod.values) (p, p.label(context.l10n))],
    value: value,
    onChanged: onChanged,
  );
}
