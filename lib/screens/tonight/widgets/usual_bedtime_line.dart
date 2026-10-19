import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../utils/formatters.dart';
import '../../../utils/sleep_stats.dart';

class UsualBedtimeLine extends StatelessWidget {
  const UsualBedtimeLine({
    super.key,
    required this.usualBedtime,
    required this.nightsUsed,
    required this.isSleeping,
  });

  final TimeOfDay? usualBedtime; // null when there isn't enough data
  final int nightsUsed;
  final bool isSleeping;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: 14, color: context.colors.ink2);
    final InlineSpan span;
    if (isSleeping) {
      span = const TextSpan(text: 'Sweet dreams. Tap the bedtime card to adjust it.');
    } else if (usualBedtime == null) {
      span = const TextSpan(text: 'Your usual bedtime shows up after $minNights nights');
    } else {
      span = TextSpan(
        children: [
          const TextSpan(text: 'Usual bedtime '),
          TextSpan(
            text: fmtTimeOfDay(usualBedtime!),
            style: TextStyle(fontWeight: FontWeight.w700, color: context.colors.ink),
          ),
          TextSpan(text: ' · last $nightsUsed nights'),
        ],
      );
    }
    return Text.rich(span, style: style, textAlign: TextAlign.center);
  }
}
