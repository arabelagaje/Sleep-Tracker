import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.value, this.onChanged, this.size = 16, this.gap = 2});

  final int? value; // 1–5, null = unrated
  final ValueChanged<int?>? onChanged; // null = read-only
  final double size;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final on = value != null && i < value!;
        final star = Icon(
          on ? Icons.star_rounded : Icons.star_outline_rounded,
          size: size,
          color: on ? c.star : c.muted,
        );
        if (onChanged == null) return star;
        final v = i + 1;
        return Semantics(
          button: true,
          label: 'Rate $v of 5',
          child: InkResponse(
            radius: size,
            // Tapping the current rating clears it.
            onTap: () => onChanged!(value == v ? null : v),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: gap, vertical: 4),
              child: star,
            ),
          ),
        );
      }),
    );
  }
}
