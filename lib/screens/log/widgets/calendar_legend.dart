import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = TextStyle(fontSize: 12, color: c.ink2);
    return Row(
      children: [
        Text('Less', style: style),
        for (final i in [1, 2, 3, 4])
          Container(
            width: 18,
            height: 12,
            margin: const EdgeInsets.only(left: 6),
            decoration: BoxDecoration(color: c.heat[i], borderRadius: BorderRadius.circular(4)),
          ),
        const SizedBox(width: 6),
        Text('More sleep', style: style),
      ],
    );
  }
}
