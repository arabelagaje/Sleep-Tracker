import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

enum LogFilter { all, unrated, withNotes, underGoal }

class LogFilterChips extends StatelessWidget {
  const LogFilterChips({super.key, required this.value, required this.onChanged});

  final LogFilter value;
  final ValueChanged<LogFilter> onChanged;

  static const _labels = {
    LogFilter.all: 'All',
    LogFilter.unrated: 'Unrated',
    LogFilter.withNotes: 'With notes',
    LogFilter.underGoal: 'Under goal',
  };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final f in LogFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Semantics(
                selected: f == value,
                button: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => onChanged(f),
                  child: Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: f == value ? c.accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: f == value ? c.accent : c.line),
                    ),
                    child: Text(
                      _labels[f]!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: f == value ? c.onAccent : c.ink2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
