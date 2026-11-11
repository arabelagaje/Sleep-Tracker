import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../../theme/app_theme.dart';

// Shade scale: time slept ÷ goal, from ½× (lightest) to 1½× (darkest).
class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final style = TextStyle(fontSize: 11, color: c.ink2, fontWeight: FontWeight.w600);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(colors: [for (var i = 0; i <= 10; i++) c.heatAt(i / 10)]),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l.legendHalfGoal, style: style),
            Text(l.legendGoal, style: style),
            Text(l.legendOneAndHalfGoal, style: style),
          ],
        ),
      ],
    );
  }
}
