import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/medication.dart';
import '../../domain/repositories/i_medication_repository.dart';
import '../models/medication_model.dart';

class MedicationRepositoryImpl implements IMedicationRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  MedicationRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
Stream<List<MedicationEntity>> getPatientMedications(String patientId) {
  return _firestore
      .collection('medications')
      .where('patientId', isEqualTo: patientId)
      .where('isDeleted', isEqualTo: false)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .asyncMap((snapshot) async {
    try {
      final medications = <MedicationEntity>[];
      for (final doc in snapshot.docs) {
        final schedules = await _getSchedules(doc.id);
        medications.add(MedicationModel.fromFirestore(doc, schedules));
      }
      return medications;
    } catch (e) {
      print('Error loading medications: $e');
      return <MedicationEntity>[];
    }
  }).handleError((error) {
    print('Stream error: $error');
    return <MedicationEntity>[];
  });
}

  Future<List<ScheduleModel>> _getSchedules(String medicationId) async {
    final snapshot = await _firestore
        .collection('medications')
        .doc(medicationId)
        .collection('schedules')
        .get();
    return snapshot.docs
        .map((doc) => ScheduleModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
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
  }) async {
    try {
      final medicationId = _uuid.v4();
      final now = DateTime.now();

      final medication = MedicationModel(
        id: medicationId,
        patientId: patientId,
        name: name,
        nameAr: nameAr,
        dosage: dosage,
        unit: unit,
        form: form,
        instructions: instructions,
        startDate: startDate,
        endDate: endDate,
        isActive: true,
        isDeleted: false,
        createdBy: createdBy,
        createdAt: now,
        schedules: schedules,
        boxImageUrl: boxImageUrl,
        boxColorHex: boxColorHex,
        pillShape: pillShape,
        pillColorHex: pillColorHex,
      );

      // حفظ الدواء
      await _firestore
          .collection('medications')
          .doc(medicationId)
          .set(medication.toFirestore());

      // حفظ الـ schedules في subcollection
      for (final schedule in schedules) {
        final scheduleModel = ScheduleModel(
          id: schedule.id,
          times: schedule.times,
          frequency: schedule.frequency,
          daysOfWeek: schedule.daysOfWeek,
          reminderMinutesBefore: schedule.reminderMinutesBefore,
        );
        await _firestore
            .collection('medications')
            .doc(medicationId)
            .collection('schedules')
            .doc(schedule.id)
            .set(scheduleModel.toMap());
      }

      return medication;
    } catch (e) {
      throw const ServerFailure('فشل في إضافة الدواء');
    }
  }

  @override
  Future<void> updateMedication(MedicationEntity medication) async {
    try {
      final model = MedicationModel(
        id: medication.id,
        patientId: medication.patientId,
        name: medication.name,
        nameAr: medication.nameAr,
        dosage: medication.dosage,
        unit: medication.unit,
        form: medication.form,
        instructions: medication.instructions,
        startDate: medication.startDate,
        endDate: medication.endDate,
        isActive: medication.isActive,
        isDeleted: medication.isDeleted,
        createdBy: medication.createdBy,
        createdAt: medication.createdAt,
        schedules: medication.schedules,
        boxImageUrl: medication.boxImageUrl,
        boxColorHex: medication.boxColorHex,
        pillShape: medication.pillShape,
        pillColorHex: medication.pillColorHex,
      );

      await _firestore
          .collection('medications')
          .doc(medication.id)
          .update(model.toFirestore());

      // تحديث الـ schedules
      final existingSchedules = await _firestore
          .collection('medications')
          .doc(medication.id)
          .collection('schedules')
          .get();

      for (final doc in existingSchedules.docs) {
        await doc.reference.delete();
      }

      for (final schedule in medication.schedules) {
        final scheduleModel = ScheduleModel(
          id: schedule.id,
          times: schedule.times,
          frequency: schedule.frequency,
          daysOfWeek: schedule.daysOfWeek,
          reminderMinutesBefore: schedule.reminderMinutesBefore,
        );
        await _firestore
            .collection('medications')
            .doc(medication.id)
            .collection('schedules')
            .doc(schedule.id)
            .set(scheduleModel.toMap());
      }
    } catch (e) {
      throw const ServerFailure('فشل في تحديث الدواء');
    }
  }

  @override
  Future<void> deleteMedication(String medicationId) async {
    try {
      await _firestore
          .collection('medications')
          .doc(medicationId)
          .update({'isDeleted': true, 'isActive': false});
    } catch (e) {
      throw const ServerFailure('فشل في حذف الدواء');
    }
  }

  @override
  Future<MedicationEntity?> getMedicationById(String medicationId) async {
    try {
      final doc = await _firestore
          .collection('medications')
          .doc(medicationId)
          .get();
      if (!doc.exists) return null;
      final schedules = await _getSchedules(medicationId);
      return MedicationModel.fromFirestore(doc, schedules);
    } catch (e) {
      return null;
    }
  }
}