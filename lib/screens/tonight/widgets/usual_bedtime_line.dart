import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
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
    final l = context.l10n;
    final text = isSleeping
        ? l.sweetDreams
        : usualBedtime == null
        ? l.usualBedtimeAfter(minNights)
        : l.usualBedtimeLine(nightsUsed, fmtTimeOfDay(context, usualBedtime!));
    return Text(
      text,
      style: TextStyle(fontSize: 14, color: context.colors.ink2),
      textAlign: TextAlign.center,
    );
  }
}
