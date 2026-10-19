import 'package:flutter/material.dart';

import '../../../models/sleep_session.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/empty_note.dart';
import '../../../widgets/section_card.dart';
import '../../../widgets/star_rating.dart';

class LastNightCard extends StatelessWidget {
  const LastNightCard({
    super.key,
    this.session,
    this.deltaVsAverage,
    required this.onEdit,
    required this.onRate,
  });

  final SleepSession? session;
  final Duration? deltaVsAverage; // null hides the comparison
  final VoidCallback onEdit;
  final ValueChanged<int?> onRate;

  String? get _deltaText {
    final d = deltaVsAverage;
    if (d == null) return null;
    if (d.inMinutes.abs() < 5) return 'right on your average';
    return '${fmtDur(d.abs())} ${d.isNegative ? 'below' : 'above'} average';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = session;
    if (s == null) {
      return const SectionCard(
        title: 'Last night',
        child: EmptyNote(
          message:
              'Your first night shows up here. Tap the moon at bedtime, or add a past night from Log.',
        ),
      );
    }
    return SectionCard(
      title: 'Last night',
      trailing: CardLink('Edit', onPressed: onEdit),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  fmtDur(s.length),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.2,
                    height: 1,
                  ),
                ),
              ),
              if (_deltaText != null)
                Text(
                  _deltaText!,
                  style: TextStyle(fontSize: 13, color: c.ink2, fontWeight: FontWeight.w500),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.quality == null ? 'How was it?' : 'Your rating',
                style: TextStyle(color: c.ink2, fontSize: 14),
              ),
              StarRating(value: s.quality, onChanged: onRate, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(12)),
            child: Text(
              s.hasNotes ? s.notes! : 'No notes yet — tap Edit to add some.',
              style: TextStyle(fontSize: 14, color: c.ink2),
            ),
          ),
        ],
      ),
    );
  }
}
