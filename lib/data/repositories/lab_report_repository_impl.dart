import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../core/error/failures.dart';
import '../../core/services/ai_lab_analysis_service.dart';
import '../../domain/entities/lab_report.dart';
import '../../domain/entities/health_recommendation.dart';
import '../../domain/repositories/i_lab_report_repository.dart';
import '../models/lab_report_model.dart';

class LabReportRepositoryImpl implements ILabReportRepository {
  final FirebaseFirestore _firestore;
  final AILabAnalysisService _aiService;
  final _uuid = const Uuid();

  LabReportRepositoryImpl({
    required FirebaseFirestore firestore,
    required AILabAnalysisService aiService,
  })  : _firestore = firestore,
        _aiService = aiService;

  @override
  Future<LabReportEntity> uploadAndAnalyzeReport({
    required String patientId,
    required File imageFile,
    required String reportType,
    required String title,
    required List<String> patientChronicConditions,
  }) async {
    try {
      final reportId = _uuid.v4();
      final now = DateTime.now();

      // Perform AI OCR Vision Parsing
      final aiAnalysis = await _aiService.analyzeLabReportImage(
        imageFile: imageFile,
        reportType: reportType,
        chronicConditions: patientChronicConditions,
      );

      // In production, imageFile is uploaded to Firebase Storage or local app storage.
      // Here we store path or reference URL:
      final imageUrl = imageFile.path;

      final reportModel = LabReportModel(
        id: reportId,
        patientId: patientId,
        imageUrl: imageUrl,
        reportType: reportType,
        title: title.isNotEmpty ? title : 'تقرير $reportType المعملي',
        reportDate: now,
        biomarkers: aiAnalysis.biomarkers,
        aiSummaryAr: aiAnalysis.summaryAr,
        aiSummaryEn: aiAnalysis.summaryEn,
        recommendedFoodsAr: aiAnalysis.recommendedFoodsAr,
        avoidFoodsAr: aiAnalysis.avoidFoodsAr,
        safeExercisesAr: aiAnalysis.safeExercisesAr,
        createdAt: now,
      );

      await _firestore
          .collection('lab_reports')
          .doc(reportId)
          .set(reportModel.toFirestore());

      return reportModel;
    } catch (e) {
      throw ServerFailure('فشل في تحليل وحفظ تقرير التحليل: $e');
    }
  }

  @override
  Stream<List<LabReportEntity>> getPatientLabReports(String patientId) {
    return _firestore
        .collection('lab_reports')
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => LabReportModel.fromFirestore(doc))
          .toList();
    }).handleError((error) {
      return <LabReportEntity>[];
    });
  }

  @override
  Future<LabReportEntity?> getLabReportById(String reportId) async {
    try {
      final doc =
          await _firestore.collection('lab_reports').doc(reportId).get();
      if (!doc.exists) return null;
      return LabReportModel.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deleteLabReport(String reportId) async {
    try {
      await _firestore.collection('lab_reports').doc(reportId).delete();
    } catch (e) {
      throw const ServerFailure('فشل في حذف التقرير الطبي');
    }
  }

  @override
  Future<List<HealthRecommendationEntity>> getPersonalizedRecommendations({
    required String patientId,
    required List<String> chronicDiseases,
    required List<LabReportEntity> recentLabReports,
  }) async {
    return _aiService.generatePersonalizedRecommendations(
      patientId: patientId,
      chronicDiseases: chronicDiseases,
      recentLabReports: recentLabReports,
    );
  }
}
