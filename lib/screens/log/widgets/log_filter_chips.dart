import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../../theme/app_theme.dart';

enum LogFilter { all, unrated, withNotes, underGoal }

class LogFilterChips extends StatelessWidget {
  const LogFilterChips({super.key, required this.value, required this.onChanged});

  final LogFilter value;
  final ValueChanged<LogFilter> onChanged;

  static String _label(AppLocalizations l, LogFilter f) => switch (f) {
    LogFilter.all => l.filterAll,
    LogFilter.unrated => l.filterUnrated,
    LogFilter.withNotes => l.filterWithNotes,
    LogFilter.underGoal => l.underGoal,
  };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
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
                      _label(l, f),
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
