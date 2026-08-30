import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/pair.dart';

class PairModel extends PairEntity {
  const PairModel({
    required super.id,
    required super.patientId,
    required super.caregiverId,
    required super.patientName,
    required super.caregiverName,
    required super.status,
    required super.pairedAt,
    super.revokedAt,
  });

  factory PairModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PairModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      caregiverId: data['caregiverId'] ?? '',
      patientName: data['patientName'] ?? '',
      caregiverName: data['caregiverName'] ?? '',
      status: data['status'] == 'active'
          ? PairStatus.active
          : PairStatus.revoked,
      pairedAt: (data['pairedAt'] as Timestamp).toDate(),
      revokedAt: data['revokedAt'] != null
          ? (data['revokedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'caregiverId': caregiverId,
      'patientName': patientName,
      'caregiverName': caregiverName,
      'status': status == PairStatus.active ? 'active' : 'revoked',
      'pairedAt': Timestamp.fromDate(pairedAt),
      'revokedAt': revokedAt != null
          ? Timestamp.fromDate(revokedAt!)
          : null,
    };
  }
}