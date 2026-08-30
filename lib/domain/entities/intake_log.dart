enum IntakeStatus { pending, taken, missed, snoozed }

class IntakeLogEntity {
  final String id;
  final String medicationId;
  final String medicationName;
  final String patientId;
  final DateTime scheduledTime;
  final DateTime? respondedAt;
  final IntakeStatus status;
  final int snoozeCount;
  final String? note;
  final String source;

  const IntakeLogEntity({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.patientId,
    required this.scheduledTime,
    this.respondedAt,
    required this.status,
    required this.snoozeCount,
    this.note,
    required this.source,
  });

  IntakeLogEntity copyWith({
    IntakeStatus? status,
    DateTime? respondedAt,
    int? snoozeCount,
    String? note,
  }) {
    return IntakeLogEntity(
      id: id,
      medicationId: medicationId,
      medicationName: medicationName,
      patientId: patientId,
      scheduledTime: scheduledTime,
      respondedAt: respondedAt ?? this.respondedAt,
      status: status ?? this.status,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      note: note ?? this.note,
      source: source,
    );
  }
}