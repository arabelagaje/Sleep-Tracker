import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key, required this.now, required this.onOpenMenu});

  final DateTime now;
  final VoidCallback onOpenMenu;

  String _greeting(AppLocalizations l) {
    final h = now.hour;
    if (h < 5 || h >= 18) return l.goodEvening;
    return h < 12 ? l.goodMorning : l.goodAfternoon;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 10, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fmtLong(now),
                  style: TextStyle(fontSize: 13, color: c.ink2, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  _greeting(l),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l.moreOptions,
            icon: Icon(Icons.more_vert, color: c.ink2),
            onPressed: onOpenMenu,
          ),
        ],
      ),
    );
  }
}
