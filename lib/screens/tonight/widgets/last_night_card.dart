import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
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

  String? _deltaText(AppLocalizations l) {
    final d = deltaVsAverage;
    if (d == null) return null;
    if (d.inMinutes.abs() < 5) return l.rightOnAverage;
    return '${fmtDur(l, d.abs())} ${d.isNegative ? 'below' : 'above'} average';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final s = session;
    final delta = _deltaText(l);
    if (s == null) {
      return SectionCard(
        title: l.previousSleep,
        child: EmptyNote(message: l.previousSleepEmpty),
      );
    }
    return SectionCard(
      title: l.previousSleep,
      trailing: CardLink(l.edit, onPressed: onEdit),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  fmtDur(context.l10n, s.length),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.2,
                    height: 1,
                  ),
                ),
              ),
              if (delta != null)
                Text(
                  delta,
                  style: TextStyle(fontSize: 13, color: c.ink2, fontWeight: FontWeight.w500),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.quality == null ? l.howWasIt : l.yourRating,
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
              s.hasNotes ? s.notes! : l.noNotesYet,
              style: TextStyle(fontSize: 14, color: c.ink2),
            ),
          ),
        ],
      ),
    );
  }
}
