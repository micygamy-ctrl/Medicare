class PairEntity {
  final String id;
  final String patientId;
  final String caregiverId;
  final String patientName;
  final String caregiverName;
  final PairStatus status;
  final DateTime pairedAt;
  final DateTime? revokedAt;

  const PairEntity({
    required this.id,
    required this.patientId,
    required this.caregiverId,
    required this.patientName,
    required this.caregiverName,
    required this.status,
    required this.pairedAt,
    this.revokedAt,
  });
}

enum PairStatus { active, revoked }