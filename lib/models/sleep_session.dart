class SleepSession {
  final int? id;
  final DateTime bedTime;
  final DateTime? wakeTime;
  final int? quality; // 1-5 stars
  final String? notes;
  final DateTime createdAt;

  SleepSession({
    this.id,
    required this.bedTime,
    this.wakeTime,
    this.quality,
    this.notes,
    required this.createdAt,
  });

  // Computed property: duration in minutes
  int? get duration {
    if (wakeTime == null) return null;
    return wakeTime!.difference(bedTime).inMinutes;
  }

  // Convert SleepSession to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bed_time': bedTime.millisecondsSinceEpoch,
      'wake_time': wakeTime?.millisecondsSinceEpoch,
      'duration': duration,
      'quality': quality,
      'notes': notes,
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
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  // Create a copy of SleepSession with optional field updates
  SleepSession copyWith({
    int? id,
    DateTime? bedTime,
    DateTime? wakeTime,
    int? quality,
    String? notes,
    DateTime? createdAt,
  }) {
    return SleepSession(
      id: id ?? this.id,
      bedTime: bedTime ?? this.bedTime,
      wakeTime: wakeTime ?? this.wakeTime,
      quality: quality ?? this.quality,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Check if session is currently active (no wake time)
  bool get isActive => wakeTime == null;

  @override
  String toString() {
    return 'SleepSession(id: $id, bedTime: $bedTime, wakeTime: $wakeTime, duration: $duration, quality: $quality)';
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
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        bedTime.hashCode ^
        wakeTime.hashCode ^
        quality.hashCode ^
        notes.hashCode ^
        createdAt.hashCode;
  }
}
