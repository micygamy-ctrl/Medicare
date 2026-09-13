import 'dart:io';
import '../entities/lab_report.dart';
import '../entities/health_recommendation.dart';

abstract class ILabReportRepository {
  /// Uploads a lab report photo, performs AI OCR parsing, and saves the report to Firestore
  Future<LabReportEntity> uploadAndAnalyzeReport({
    required String patientId,
    required File imageFile,
    required String reportType,
    required String title,
    required List<String> patientChronicConditions,
  });

  /// Streams all lab reports for a patient sorted by date
  Stream<List<LabReportEntity>> getPatientLabReports(String patientId);

  /// Fetches a single lab report by ID
  Future<LabReportEntity?> getLabReportById(String reportId);

  /// Deletes a lab report
  Future<void> deleteLabReport(String reportId);

  /// Generates personalized daily nutrition and exercise recommendations based on chronic conditions & latest lab reports
  Future<List<HealthRecommendationEntity>> getPersonalizedRecommendations({
    required String patientId,
    required List<String> chronicDiseases,
    required List<LabReportEntity> recentLabReports,
  });
}
