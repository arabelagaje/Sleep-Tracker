import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class StatTileData {
  final String label;
  final String value;
  final Widget? caption;
  const StatTileData(this.label, this.value, [this.caption]);
}

class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.label, required this.value, this.caption});

  final String label;
  final String value; // "—" when not available
  final Widget? caption; // text, delta arrow or stars

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: c.ink2, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          if (caption != null)
            DefaultTextStyle.merge(
              style: TextStyle(fontSize: 12, color: c.ink2),
              child: caption!,
            ),
        ],
      ),
    );
  }
}
