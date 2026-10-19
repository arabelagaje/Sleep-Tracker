import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key, required this.now, required this.onOpenMenu});

  final DateTime now;
  final VoidCallback onOpenMenu;

  String get _greeting {
    final h = now.hour;
    if (h < 5 || h >= 18) return 'Good evening';
    return h < 12 ? 'Good morning' : 'Good afternoon';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
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
                  _greeting,
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
            tooltip: 'More options',
            icon: Icon(Icons.more_vert, color: c.ink2),
            onPressed: onOpenMenu,
          ),
        ],
      ),
    );
  }
}
