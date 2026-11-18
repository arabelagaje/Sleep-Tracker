import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/l10n.dart';

// Everything here formats in the app's language. Dates and durations take the
// app's strings (context.l10n) so the quick tile can use them without a screen;
// clock times take the context because they also follow the phone's 24-hour setting.

// "7h 45m", "8h", "40m"
String fmtDur(AppLocalizations l, Duration d) {
  final m = d.inMinutes < 0 ? 0 : d.inMinutes;
  if (m < 60) return l.durMinutes(m);
  final h = m ~/ 60, r = m % 60;
  return r == 0 ? l.durHours(h) : l.durHoursMinutes(h, r);
}

// "7.8h"
String fmtHours(AppLocalizations l, Duration d) =>
    l.durHoursDecimal(NumberFormat('0.0', l.localeName).format(d.inMinutes / 60));

// "11:43 PM", or "23:43" when the phone is set to 24-hour. Uses Flutter's own
// time format for the language, so it matches the time picker.
String fmtClock(BuildContext context, DateTime d) =>
    fmtTimeOfDay(context, TimeOfDay.fromDateTime(d));

String fmtTimeOfDay(BuildContext context, TimeOfDay t) => MaterialLocalizations.of(
  context,
).formatTimeOfDay(t, alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context));

// Chart axis label for a whole hour: "8p", or "20" on a 24-hour phone or language
String fmtAxisHour(BuildContext context, int hour) {
  final format = MaterialLocalizations.of(
    context,
  ).timeOfDayFormat(alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context));
  if (hourFormat(of: format) != HourFormat.h) return hour.toString().padLeft(2, '0');
  final h = hour % 12 == 0 ? 12 : hour % 12;
  return hour < 12 ? context.l10n.axisHourAm(h) : context.l10n.axisHourPm(h);
}

// "Sun, Oct 18"
String fmtDay(AppLocalizations l, DateTime d) => DateFormat.MMMEd(l.localeName).format(d);

// "Oct 18"
String fmtMonthDay(AppLocalizations l, DateTime d) => DateFormat.MMMd(l.localeName).format(d);

// "Sun"
String fmtDow(AppLocalizations l, DateTime d) => DateFormat.E(l.localeName).format(d);

// "S": one-letter weekday for narrow columns
String fmtDowNarrow(AppLocalizations l, DateTime d) => DateFormat('EEEEE', l.localeName).format(d);

// "Sunday, October 18"
String fmtLong(AppLocalizations l, DateTime d) => DateFormat.MMMMEEEEd(l.localeName).format(d);

// "October 2026"
String fmtMonth(AppLocalizations l, DateTime d) => DateFormat.yMMMM(l.localeName).format(d);

// "01:02:03"
String fmtTimer(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
}
