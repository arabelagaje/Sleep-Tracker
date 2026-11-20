import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/formatters.dart';

class SleepGoalStepper extends StatelessWidget {
  const SleepGoalStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = const Duration(hours: 4),
    this.max = const Duration(hours: 12),
    this.step = const Duration(minutes: 30),
  });

  final Duration value;
  final ValueChanged<Duration> onChanged;
  final Duration min, max, step;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget btn(String label, String semantic, VoidCallback? onTap) => Semantics(
      label: semantic,
      button: true,
      child: Material(
        color: c.surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: c.line),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: onTap == null ? c.muted : c.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        btn('−', context.l10n.decreaseGoal, value <= min ? null : () => onChanged(value - step)),
        SizedBox(
          width: 58,
          child: Text(
            fmtDur(context.l10n, value),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        btn('+', context.l10n.increaseGoal, value >= max ? null : () => onChanged(value + step)),
      ],
    );
  }
}
