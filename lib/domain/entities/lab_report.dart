enum BiomarkerStatus { normal, high, low }

class BiomarkerResult {
  final String name;
  final String nameAr;
  final String value;
  final String unit;
  final String referenceRange;
  final BiomarkerStatus status;

  const BiomarkerResult({
    required this.name,
    required this.nameAr,
    required this.value,
    required this.unit,
    required this.referenceRange,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'nameAr': nameAr,
      'value': value,
      'unit': unit,
      'referenceRange': referenceRange,
      'status': status.name,
    };
  }

  factory BiomarkerResult.fromMap(Map<String, dynamic> map) {
    return BiomarkerResult(
      name: map['name'] ?? '',
      nameAr: map['nameAr'] ?? '',
      value: map['value'] ?? '',
      unit: map['unit'] ?? '',
      referenceRange: map['referenceRange'] ?? '',
      status: BiomarkerStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BiomarkerStatus.normal,
      ),
    );
  }
}

class LabReportEntity {
  final String id;
  final String patientId;
  final String imageUrl;
  final String reportType; // e.g. 'CBC', 'Glucose', 'Lipid', 'Kidney', 'Liver', 'General'
  final String title;
  final DateTime reportDate;
  final List<BiomarkerResult> biomarkers;
  final String aiSummaryAr;
  final String aiSummaryEn;
  final List<String> recommendedFoodsAr;
  final List<String> avoidFoodsAr;
  final List<String> safeExercisesAr;
  final DateTime createdAt;

  const LabReportEntity({
    required this.id,
    required this.patientId,
    required this.imageUrl,
    required this.reportType,
    required this.title,
    required this.reportDate,
    required this.biomarkers,
    required this.aiSummaryAr,
    required this.aiSummaryEn,
    required this.recommendedFoodsAr,
    required this.avoidFoodsAr,
    required this.safeExercisesAr,
    required this.createdAt,
  });
}
