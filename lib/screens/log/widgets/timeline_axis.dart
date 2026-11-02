import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../utils/formatters.dart';

// Shared column widths for the axis and every row.
const double timelineDayWidth = 52, timelineValueWidth = 76, timelineGap = 8;

class TimelineAxis extends StatelessWidget {
  const TimelineAxis({super.key});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 10.5,
      color: context.colors.ink2,
      fontWeight: FontWeight.w600,
    );
    return Row(
      children: [
        const SizedBox(width: timelineDayWidth + timelineGap),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final h in [18, 21, 0, 3, 6, 9, 12]) Text(fmtAxisHour(context, h), style: style),
            ],
          ),
        ),
        const SizedBox(width: timelineValueWidth + timelineGap),
      ],
    );
  }
}
