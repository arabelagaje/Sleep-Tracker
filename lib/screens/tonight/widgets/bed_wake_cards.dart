import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../utils/formatters.dart';

class BedWakeCards extends StatelessWidget {
  const BedWakeCards({
    super.key,
    this.bedTime,
    this.wakeTime,
    required this.isSleeping,
    this.onTap,
  });

  final DateTime? bedTime;
  final DateTime? wakeTime;
  final bool isSleeping;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tap = bedTime == null ? null : onTap;
    return Row(
      children: [
        Expanded(
          child: _EndCard(
            icon: Icons.bedtime_outlined,
            label: isSleeping ? 'In bed since' : 'Bedtime',
            value: bedTime == null ? '—' : fmtClock(bedTime!),
            onTap: tap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _EndCard(
            icon: Icons.wb_sunny_outlined,
            label: 'Woke up',
            value: isSleeping ? 'Sleeping…' : (wakeTime == null ? '—' : fmtClock(wakeTime!)),
            onTap: tap,
          ),
        ),
      ],
    );
  }
}

class _EndCard extends StatelessWidget {
  const _EndCard({required this.icon, required this.label, required this.value, this.onTap});

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: c.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 66),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: c.accentSoft,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 18, color: c.accentInk),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(fontSize: 12, color: c.ink2, fontWeight: FontWeight.w500),
                    ),
                    Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
