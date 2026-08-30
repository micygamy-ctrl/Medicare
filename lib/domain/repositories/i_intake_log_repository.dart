import '../entities/intake_log.dart';

abstract class IIntakeLogRepository {
  Future<IntakeLogEntity> createIntakeLog({
    required String medicationId,
    required String medicationName,
    required String patientId,
    required DateTime scheduledTime,
  });

  Future<void> updateIntakeStatus({
    required String logId,
    required IntakeStatus status,
    String? note,
  });

  Stream<List<IntakeLogEntity>> getTodayLogs(String patientId);

  Future<List<IntakeLogEntity>> getLogsByDateRange({
    required String patientId,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<double> getAdherencePercentage({
    required String patientId,
    required int days,
  });
}