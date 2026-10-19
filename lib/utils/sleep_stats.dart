import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/sleep_session.dart';

// Averages need at least this many nights to mean anything.
const int minNights = 3;

// "Usual" bed/wake times use the last N nights (Tonight and Insights agree).
const int usualWindow = 14;

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);

// Minutes after 6pm, so 11pm and 1am average to midnight, not noon.
int eveMin(DateTime d) => ((d.hour + 6) % 24) * 60 + d.minute;

TimeOfDay fromEveMin(double m) {
  final total = (m.round() + 18 * 60) % (24 * 60);
  return TimeOfDay(hour: total ~/ 60, minute: total % 60);
}

Duration averageDuration(List<SleepSession> list) {
  if (list.isEmpty) return Duration.zero;
  final total = list.fold<int>(0, (a, s) => a + s.length.inMinutes);
  return Duration(minutes: (total / list.length).round());
}

double _mean(Iterable<num> xs) => xs.isEmpty ? 0 : xs.fold<num>(0, (a, b) => a + b) / xs.length;

// Finished nights whose wake-up falls in the [n] calendar days ending
// [offset] days before [today].
List<SleepSession> inLastDays(
  List<SleepSession> sessions,
  DateTime today,
  int n, {
  int offset = 0,
}) {
  final end = addDays(today, 1 - offset);
  final start = addDays(end, -n);
  return sessions
      .where((s) => s.wakeTime != null && !s.wakeTime!.isBefore(start) && s.wakeTime!.isBefore(end))
      .toList();
}

// Monday of the week containing [d].
DateTime weekStart(DateTime d) => addDays(dateOnly(d), -(d.weekday - 1));

// Calendar shade 1–4 by duration against the goal.
int sleepLevel(Duration d, Duration goal) {
  final m = d.inMinutes;
  if (m < 360) return 1;
  if (m < 420) return 2;
  if (m < goal.inMinutes) return 3;
  return 4;
}

class UsualTimes {
  final TimeOfDay bed;
  final TimeOfDay wake;
  final int nightsUsed;
  const UsualTimes(this.bed, this.wake, this.nightsUsed);
}

// Null when there are fewer than [minNights] finished nights.
// [sessions] must be newest first.
UsualTimes? usualTimes(List<SleepSession> sessions) {
  final recent = sessions.take(usualWindow).toList();
  if (recent.length < minNights) return null;
  return UsualTimes(
    fromEveMin(_mean(recent.map((s) => eveMin(s.bedTime)))),
    fromEveMin(_mean(recent.map((s) => eveMin(s.wakeTime!)))),
    recent.length,
  );
}

class PeriodStats {
  final int count;
  final Duration average;
  final SleepSession longest;
  final SleepSession shortest;
  final TimeOfDay avgBed;
  final int bedSpreadMinutes; // standard deviation of bedtime
  final TimeOfDay avgWake;
  final double? avgQuality;
  final int rated;

  const PeriodStats({
    required this.count,
    required this.average,
    required this.longest,
    required this.shortest,
    required this.avgBed,
    required this.bedSpreadMinutes,
    required this.avgWake,
    required this.avgQuality,
    required this.rated,
  });

  // Null for an empty list.
  static PeriodStats? of(List<SleepSession> list) {
    if (list.isEmpty) return null;
    final bedMins = list.map((s) => eveMin(s.bedTime)).toList();
    final meanBed = _mean(bedMins);
    final sd = math.sqrt(_mean(bedMins.map((m) => (m - meanBed) * (m - meanBed))));
    final ratings = list.where((s) => s.quality != null).map((s) => s.quality!);
    return PeriodStats(
      count: list.length,
      average: averageDuration(list),
      longest: list.reduce((a, b) => b.length > a.length ? b : a),
      shortest: list.reduce((a, b) => b.length < a.length ? b : a),
      avgBed: fromEveMin(meanBed),
      bedSpreadMinutes: sd.round(),
      avgWake: fromEveMin(_mean(list.map((s) => eveMin(s.wakeTime!)))),
      avgQuality: ratings.isEmpty ? null : _mean(ratings).toDouble(),
      rated: ratings.length,
    );
  }
}
