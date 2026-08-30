import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/intake_log.dart';

class IntakeLogModel extends IntakeLogEntity {
  const IntakeLogModel({
    required super.id,
    required super.medicationId,
    required super.medicationName,
    required super.patientId,
    required super.scheduledTime,
    super.respondedAt,
    required super.status,
    required super.snoozeCount,
    super.note,
    required super.source,
  });

  factory IntakeLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return IntakeLogModel(
      id: doc.id,
      medicationId: data['medicationId'] ?? '',
      medicationName: data['medicationName'] ?? '',
      patientId: data['patientId'] ?? '',
      scheduledTime: (data['scheduledTime'] as Timestamp).toDate(),
      respondedAt: data['respondedAt'] != null
          ? (data['respondedAt'] as Timestamp).toDate()
          : null,
      status: _statusFromString(data['status']),
      snoozeCount: data['snoozeCount'] ?? 0,
      note: data['note'],
      source: data['source'] ?? 'patient',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'medicationId': medicationId,
      'medicationName': medicationName,
      'patientId': patientId,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'respondedAt':
          respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'status': _statusToString(status),
      'snoozeCount': snoozeCount,
      'note': note,
      'source': source,
    };
  }

  static IntakeStatus _statusFromString(String? value) {
    switch (value) {
      case 'taken':
        return IntakeStatus.taken;
      case 'missed':
        return IntakeStatus.missed;
      case 'snoozed':
        return IntakeStatus.snoozed;
      default:
        return IntakeStatus.pending;
    }
  }

  static String _statusToString(IntakeStatus status) {
    switch (status) {
      case IntakeStatus.taken:
        return 'taken';
      case IntakeStatus.missed:
        return 'missed';
      case IntakeStatus.snoozed:
        return 'snoozed';
      default:
        return 'pending';
    }
  }
}