class SleepSession {
  final int? id;
  final DateTime bedTime;
  final DateTime? wakeTime;
  final int? quality; // 1-5 stars
  final String? notes;
  final bool isNap; // naps are kept out of nights, stats and charts
  final DateTime createdAt;

  SleepSession({
    this.id,
    required this.bedTime,
    this.wakeTime,
    this.quality,
    this.notes,
    this.isNap = false,
    required this.createdAt,
  });

  // A session that ends between 10am and 9pm and lasts under 4h is saved as a
  // nap when stopped. Dated by wake time, like nights.
  static bool looksLikeNap(DateTime bed, DateTime wake) =>
      wake.hour >= 10 && wake.hour < 21 && wake.difference(bed) < const Duration(hours: 4);

  // Computed property: duration in minutes
  int? get duration {
    if (wakeTime == null) return null;
    return wakeTime!.difference(bedTime).inMinutes;
  }

  // Duration of a finished session (zero while still sleeping)
  Duration get length => wakeTime == null ? Duration.zero : wakeTime!.difference(bedTime);

  // A night is named by the morning you woke up (date only)
  DateTime get nightDate {
    final w = wakeTime ?? bedTime;
    return DateTime(w.year, w.month, w.day);
  }

  bool get hasNotes => notes != null && notes!.trim().isNotEmpty;

  // Convert SleepSession to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bed_time': bedTime.millisecondsSinceEpoch,
      'wake_time': wakeTime?.millisecondsSinceEpoch,
      'quality': quality,
      'notes': notes,
      'is_nap': isNap ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  // Create SleepSession from Map (database row)
  factory SleepSession.fromMap(Map<String, dynamic> map) {
    return SleepSession(
      id: map['id'] as int?,
      bedTime: DateTime.fromMillisecondsSinceEpoch(map['bed_time'] as int),
      wakeTime: map['wake_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['wake_time'] as int)
          : null,
      quality: map['quality'] as int?,
      notes: map['notes'] as String?,
      isNap: map['is_nap'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  // Create a copy of SleepSession with optional field updates.
  // The clear* flags set nullable fields back to null.
  SleepSession copyWith({
    int? id,
    DateTime? bedTime,
    DateTime? wakeTime,
    int? quality,
    String? notes,
    bool? isNap,
    DateTime? createdAt,
    bool clearWakeTime = false,
    bool clearQuality = false,
    bool clearNotes = false,
  }) {
    return SleepSession(
      id: id ?? this.id,
      bedTime: bedTime ?? this.bedTime,
      wakeTime: clearWakeTime ? null : wakeTime ?? this.wakeTime,
      quality: clearQuality ? null : quality ?? this.quality,
      notes: clearNotes ? null : notes ?? this.notes,
      isNap: isNap ?? this.isNap,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Check if session is currently active (no wake time)
  bool get isActive => wakeTime == null;

  @override
  String toString() {
    return 'SleepSession(id: $id, bedTime: $bedTime, wakeTime: $wakeTime, duration: $duration, quality: $quality, isNap: $isNap)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SleepSession &&
        other.id == id &&
        other.bedTime == bedTime &&
        other.wakeTime == wakeTime &&
        other.quality == quality &&
        other.notes == notes &&
        other.isNap == isNap &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        bedTime.hashCode ^
        wakeTime.hashCode ^
        quality.hashCode ^
        notes.hashCode ^
        isNap.hashCode ^
        createdAt.hashCode;
  }
}
