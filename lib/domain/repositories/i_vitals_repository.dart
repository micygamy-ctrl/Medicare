import '../entities/vital_sign.dart';

abstract class IVitalsRepository {
  /// Adds a new vital sign reading (manual or smartwatch synced)
  Future<VitalSignEntity> addVitalReading({
    required String patientId,
    required int systolicBP,
    required int diastolicBP,
    required int heartRate,
    required int spO2,
    required double temperature,
    required VitalSource source,
  });

  /// Syncs live simulated reading from paired Smartwatch
  Future<VitalSignEntity> syncSmartwatchReading(String patientId);

  /// Streams real-time vital readings for a patient
  Stream<List<VitalSignEntity>> getPatientVitalsStream(String patientId);

  /// Fetches latest single vital reading
  Future<VitalSignEntity?> getLatestVital(String patientId);

  /// Deletes a vital reading log
  Future<void> deleteVitalReading(String vitalId);
}
