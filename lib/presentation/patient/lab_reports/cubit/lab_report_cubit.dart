import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/lab_report.dart';
import '../../../../domain/entities/health_recommendation.dart';
import '../../../../domain/repositories/i_lab_report_repository.dart';

abstract class LabReportState extends Equatable {
  const LabReportState();

  @override
  List<Object?> get props => [];
}

class LabReportInitial extends LabReportState {}

class LabReportLoading extends LabReportState {}

class LabReportAnalyzing extends LabReportState {
  final String statusMessage;
  const LabReportAnalyzing({required this.statusMessage});

  @override
  List<Object?> get props => [statusMessage];
}

class LabReportLoaded extends LabReportState {
  final List<LabReportEntity> reports;
  final List<HealthRecommendationEntity> recommendations;

  const LabReportLoaded({
    required this.reports,
    required this.recommendations,
  });

  @override
  List<Object?> get props => [reports, recommendations];
}

class LabReportUploadedSuccess extends LabReportState {
  final LabReportEntity report;
  const LabReportUploadedSuccess(this.report);

  @override
  List<Object?> get props => [report];
}

class LabReportError extends LabReportState {
  final String message;
  const LabReportError(this.message);

  @override
  List<Object?> get props => [message];
}

class LabReportCubit extends Cubit<LabReportState> {
  final ILabReportRepository _repository;

  LabReportCubit(this._repository) : super(LabReportInitial());

  void loadPatientReports({
    required String patientId,
    required List<String> chronicDiseases,
  }) {
    emit(LabReportLoading());
    _repository.getPatientLabReports(patientId).listen(
      (reports) async {
        try {
          final recs = await _repository.getPersonalizedRecommendations(
            patientId: patientId,
            chronicDiseases: chronicDiseases,
            recentLabReports: reports,
          );
          emit(LabReportLoaded(reports: reports, recommendations: recs));
        } catch (e) {
          emit(LabReportLoaded(reports: reports, recommendations: const []));
        }
      },
      onError: (e) => emit(const LabReportError('فشل في تحميل التحاليل الطبية')),
    );
  }

  Future<void> uploadAndAnalyze({
    required String patientId,
    required File imageFile,
    required String reportType,
    required String title,
    required List<String> patientChronicConditions,
  }) async {
    emit(const LabReportAnalyzing(
        statusMessage: 'جاري استخراج بيانات التحليل بالذكاء الاصطناعي...'));
    try {
      final report = await _repository.uploadAndAnalyzeReport(
        patientId: patientId,
        imageFile: imageFile,
        reportType: reportType,
        title: title,
        patientChronicConditions: patientChronicConditions,
      );
      emit(LabReportUploadedSuccess(report));
    } catch (e) {
      emit(LabReportError(e.toString()));
    }
  }

  Future<void> deleteReport(String reportId) async {
    try {
      await _repository.deleteLabReport(reportId);
    } catch (e) {
      emit(const LabReportError('فشل في حذف التقرير'));
    }
  }
}
