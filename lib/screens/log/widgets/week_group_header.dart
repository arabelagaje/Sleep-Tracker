import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/formatters.dart';

class WeekGroupHeader extends StatelessWidget {
  const WeekGroupHeader({super.key, required this.label, this.average});

  final String label;
  final Duration? average;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 14, 2, 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
              color: c.ink2,
            ),
          ),
          if (average != null)
            Text(
              context.l10n.avgDuration(fmtDur(context.l10n, average!)),
              style: TextStyle(fontSize: 12, color: c.ink2),
            ),
        ],
      ),
    );
  }
}
