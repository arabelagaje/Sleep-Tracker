import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// "7h 45m", "8h", "40m"
String fmtDur(Duration d) {
  final m = d.inMinutes < 0 ? 0 : d.inMinutes;
  if (m < 60) return '${m}m';
  final h = m ~/ 60, r = m % 60;
  return r == 0 ? '${h}h' : '${h}h ${r}m';
}

// "7.8"
String fmtHours(Duration d) => (d.inMinutes / 60).toStringAsFixed(1);

// "11:43 PM", or "23:43" when the phone is set to 24-hour
String fmtClock(BuildContext context, DateTime d) =>
    DateFormat(MediaQuery.alwaysUse24HourFormatOf(context) ? 'HH:mm' : 'h:mm a').format(d);

String fmtTimeOfDay(BuildContext context, TimeOfDay t) =>
    fmtClock(context, DateTime(2000, 1, 1, t.hour, t.minute));

// Chart axis label for a whole hour: "8p", or "20" when the phone is set to 24-hour
String fmtAxisHour(BuildContext context, int hour) {
  if (MediaQuery.alwaysUse24HourFormatOf(context)) return hour.toString().padLeft(2, '0');
  final h = hour % 12 == 0 ? 12 : hour % 12;
  return '$h${hour < 12 ? 'a' : 'p'}';
}

// "Sun, Oct 18"
String fmtDay(DateTime d) => DateFormat('EEE, MMM d').format(d);

// "Oct 18"
String fmtMonthDay(DateTime d) => DateFormat('MMM d').format(d);

// "Sun"
String fmtDow(DateTime d) => DateFormat('EEE').format(d);

// "Sunday, October 18"
String fmtLong(DateTime d) => DateFormat('EEEE, MMMM d').format(d);

// "October 2026"
String fmtMonth(DateTime d) => DateFormat('MMMM y').format(d);

// "01:02:03"
String fmtTimer(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
}
