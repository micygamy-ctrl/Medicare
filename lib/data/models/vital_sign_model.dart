import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/vital_sign.dart';

class VitalSignModel extends VitalSignEntity {
  const VitalSignModel({
    required super.id,
    required super.patientId,
    required super.systolicBP,
    required super.diastolicBP,
    required super.heartRate,
    required super.spO2,
    required super.temperature,
    required super.source,
    required super.status,
    required super.timestamp,
  });

  factory VitalSignModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final sourceStr = data['source'] ?? 'manual';
    final source = VitalSource.values.firstWhere(
      (e) => e.name == sourceStr,
      orElse: () => VitalSource.manual,
    );

    final statusStr = data['status'] ?? 'normal';
    final status = VitalStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => VitalStatus.normal,
    );

    return VitalSignModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      systolicBP: (data['systolicBP'] as num?)?.toInt() ?? 120,
      diastolicBP: (data['diastolicBP'] as num?)?.toInt() ?? 80,
      heartRate: (data['heartRate'] as num?)?.toInt() ?? 72,
      spO2: (data['spO2'] as num?)?.toInt() ?? 98,
      temperature: (data['temperature'] as num?)?.toDouble() ?? 36.8,
      source: source,
      status: status,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'systolicBP': systolicBP,
      'diastolicBP': diastolicBP,
      'heartRate': heartRate,
      'spO2': spO2,
      'temperature': temperature,
      'source': source.name,
      'status': status.name,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
