import 'dart:async';

import 'package:flutter/material.dart';

import '../../../utils/formatters.dart';

class LiveTimerText extends StatefulWidget {
  const LiveTimerText({super.key, required this.startedAt, this.style});

  final DateTime startedAt;
  final TextStyle? style;

  @override
  State<LiveTimerText> createState() => _LiveTimerTextState();
}

class _LiveTimerTextState extends State<LiveTimerText> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = DateTime.now().difference(widget.startedAt);
    return Text(
      fmtTimer(elapsed.isNegative ? Duration.zero : elapsed),
      style: (widget.style ?? const TextStyle()).copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
