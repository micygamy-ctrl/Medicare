import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/lab_report.dart';

class LabReportModel extends LabReportEntity {
  const LabReportModel({
    required super.id,
    required super.patientId,
    required super.imageUrl,
    required super.reportType,
    required super.title,
    required super.reportDate,
    required super.biomarkers,
    required super.aiSummaryAr,
    required super.aiSummaryEn,
    required super.recommendedFoodsAr,
    required super.avoidFoodsAr,
    required super.safeExercisesAr,
    required super.createdAt,
  });

  factory LabReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final rawBiomarkers = data['biomarkers'] as List<dynamic>? ?? [];
    final biomarkersList = rawBiomarkers
        .map((b) => BiomarkerResult.fromMap(Map<String, dynamic>.from(b)))
        .toList();

    return LabReportModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      reportType: data['reportType'] ?? 'General',
      title: data['title'] ?? 'تحليل طبي',
      reportDate: (data['reportDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      biomarkers: biomarkersList,
      aiSummaryAr: data['aiSummaryAr'] ?? '',
      aiSummaryEn: data['aiSummaryEn'] ?? '',
      recommendedFoodsAr: List<String>.from(data['recommendedFoodsAr'] ?? []),
      avoidFoodsAr: List<String>.from(data['avoidFoodsAr'] ?? []),
      safeExercisesAr: List<String>.from(data['safeExercisesAr'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'imageUrl': imageUrl,
      'reportType': reportType,
      'title': title,
      'reportDate': Timestamp.fromDate(reportDate),
      'biomarkers': biomarkers.map((b) => b.toMap()).toList(),
      'aiSummaryAr': aiSummaryAr,
      'aiSummaryEn': aiSummaryEn,
      'recommendedFoodsAr': recommendedFoodsAr,
      'avoidFoodsAr': avoidFoodsAr,
      'safeExercisesAr': safeExercisesAr,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
