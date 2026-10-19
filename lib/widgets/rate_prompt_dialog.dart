import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'star_rating.dart';

// Morning prompt after Stop (Settings → "Ask me to rate in the morning").
// Returns the chosen rating, or null when skipped.
class RatePromptDialog extends StatefulWidget {
  const RatePromptDialog({super.key, required this.length});

  final Duration length;

  static Future<int?> show(BuildContext context, Duration length) => showDialog<int>(
    context: context,
    builder: (_) => RatePromptDialog(length: length),
  );

  @override
  State<RatePromptDialog> createState() => _RatePromptDialogState();
}

class _RatePromptDialogState extends State<RatePromptDialog> {
  int? _value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AlertDialog(
      title: const Text(
        'How did you sleep?',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 19),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${fmtDur(widget.length)} logged', style: TextStyle(color: c.ink2)),
          const SizedBox(height: 12),
          StarRating(
            value: _value,
            size: 34,
            gap: 4,
            onChanged: (v) {
              setState(() => _value = v);
              if (v != null) Navigator.pop(context, v);
            },
          ),
        ],
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Skip'))],
    );
  }
}
