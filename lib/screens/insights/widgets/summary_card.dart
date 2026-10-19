import 'package:flutter/material.dart';

import '../../../widgets/empty_note.dart';
import '../../../widgets/section_card.dart';
import 'period_selector.dart';
import 'stat_tile.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.period,
    required this.onPeriodChanged,
    required this.rangeLabel,
    required this.tiles,
  });

  final InsightsPeriod period;
  final ValueChanged<InsightsPeriod> onPeriodChanged;
  final String rangeLabel;
  final List<StatTileData> tiles; // empty = no nights in period

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Summary',
      trailing: CardCaption(rangeLabel),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 2),
          PeriodSelector(value: period, onChanged: onPeriodChanged),
          const SizedBox(height: 12),
          if (tiles.isEmpty)
            const EmptyNote(message: 'No nights in this period yet.')
          else
            LayoutBuilder(
              builder: (context, box) {
                final w = (box.maxWidth - 8) / 2;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in tiles)
                      SizedBox(
                        width: w,
                        child: StatTile(label: t.label, value: t.value, caption: t.caption),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
