import '../entities/pair.dart';

abstract class IPairingRepository {
  // المريض يولّد كود
  Future<String> generatePairingCode(String patientId);

  // مقدم الرعاية يدخل الكود
  Future<PairEntity> pairWithPatient({
    required String code,
    required String caregiverId,
    required String caregiverName,
  });

  // جلب الـ pair الحالي للمريض
  Future<PairEntity?> getPatientPair(String patientId);

  // جلب المرضى المرتبطين بمقدم الرعاية
  Stream<List<PairEntity>> getCaregiverPatients(String caregiverId);

  // إلغاء الارتباط
  Future<void> revokePair(String pairId);
}