import '../entities/medication.dart';

abstract class IMedicationRepository {
  Stream<List<MedicationEntity>> getPatientMedications(String patientId);

  Future<MedicationEntity> addMedication({
    required String patientId,
    required String name,
    required String nameAr,
    required String dosage,
    required String unit,
    required MedicationForm form,
    required String instructions,
    required DateTime startDate,
    DateTime? endDate,
    required String createdBy,
    required List<ScheduleEntity> schedules,
    String? boxImageUrl,
    String? boxColorHex,
    String? pillShape,
    String? pillColorHex,
  });

  Future<void> updateMedication(MedicationEntity medication);
  Future<void> deleteMedication(String medicationId);
  Future<MedicationEntity?> getMedicationById(String medicationId);
}