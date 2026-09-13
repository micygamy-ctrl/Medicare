import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/vital_sign.dart';
import '../../domain/repositories/i_vitals_repository.dart';
import '../models/vital_sign_model.dart';

class VitalsRepositoryImpl implements IVitalsRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();
  final _random = Random();

  VitalsRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<VitalSignEntity> addVitalReading({
    required String patientId,
    required int systolicBP,
    required int diastolicBP,
    required int heartRate,
    required int spO2,
    required double temperature,
    required VitalSource source,
  }) async {
    try {
      final vitalId = _uuid.v4();
      final now = DateTime.now();

      final status = VitalSignEntity.calculateStatus(
        systolic: systolicBP,
        diastolic: diastolicBP,
        heartRate: heartRate,
        spO2: spO2,
      );

      final vitalModel = VitalSignModel(
        id: vitalId,
        patientId: patientId,
        systolicBP: systolicBP,
        diastolicBP: diastolicBP,
        heartRate: heartRate,
        spO2: spO2,
        temperature: temperature,
        source: source,
        status: status,
        timestamp: now,
      );

      await _firestore
          .collection('vitals')
          .doc(vitalId)
          .set(vitalModel.toFirestore());

      // If status is critical, trigger Emergency Caregiver Notification
      if (status == VitalStatus.critical) {
        await _dispatchEmergencyAlert(vitalModel);
      }

      return vitalModel;
    } catch (e) {
      throw ServerFailure('فشل في حفظ قراءة المؤشرات الحيوية: $e');
    }
  }

  @override
  Future<VitalSignEntity> syncSmartwatchReading(String patientId) async {
    // Generate realistic smartwatch sensor vitals
    final systolic = 115 + _random.nextInt(30); // 115 - 145
    final diastolic = 75 + _random.nextInt(20); // 75 - 95
    final heartRate = 65 + _random.nextInt(40); // 65 - 105
    final spO2 = 95 + _random.nextInt(4); // 95 - 99
    final temp = 36.5 + (_random.nextInt(10) / 10.0); // 36.5 - 37.5

    return addVitalReading(
      patientId: patientId,
      systolicBP: systolic,
      diastolicBP: diastolic,
      heartRate: heartRate,
      spO2: spO2,
      temperature: double.parse(temp.toStringAsFixed(1)),
      source: VitalSource.smartwatch,
    );
  }

  @override
  Stream<List<VitalSignEntity>> getPatientVitalsStream(String patientId) {
    return _firestore
        .collection('vitals')
        .where('patientId', isEqualTo: patientId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => VitalSignModel.fromFirestore(doc))
          .toList();
    }).handleError((error) {
      return <VitalSignEntity>[];
    });
  }

  @override
  Future<VitalSignEntity?> getLatestVital(String patientId) async {
    try {
      final snapshot = await _firestore
          .collection('vitals')
          .where('patientId', isEqualTo: patientId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return VitalSignModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deleteVitalReading(String vitalId) async {
    try {
      await _firestore.collection('vitals').doc(vitalId).delete();
    } catch (e) {
      throw const ServerFailure('فشل في حذف القراءة');
    }
  }

  /// Triggers an emergency alert in Firestore `alerts` collection for Caregivers & Doctors
  Future<void> _dispatchEmergencyAlert(VitalSignModel vital) async {
    try {
      final alertId = _uuid.v4();
      await _firestore.collection('emergency_alerts').doc(alertId).set({
        'patientId': vital.patientId,
        'type': 'vital_critical',
        'messageAr':
            'تنبيه طارئ: ارتفاع حرِج في قراءات المريض (ضغط الدم ${vital.systolicBP}/${vital.diastolicBP} - NBD ${vital.heartRate} bpm)',
        'messageEn':
            'Emergency Vital Alert: Critical readings (BP ${vital.systolicBP}/${vital.diastolicBP} - HR ${vital.heartRate} bpm)',
        'vitalId': vital.id,
        'timestamp': Timestamp.fromDate(vital.timestamp),
        'isResolved': false,
      });
    } catch (e) {
      print('Emergency Alert Dispatch error: $e');
    }
  }
}
