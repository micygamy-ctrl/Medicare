import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../../../../domain/entities/medication.dart';
import '../../../../domain/repositories/i_medication_repository.dart';
import '../../../../core/utils/notification_scheduler.dart';
import '../../../../core/utils/alarm_service.dart';


// States
abstract class MedicationState extends Equatable {
  const MedicationState();

  @override
  List<Object?> get props => [];
}

class MedicationInitial extends MedicationState {}

class MedicationLoading extends MedicationState {}

class MedicationLoaded extends MedicationState {
  final List<MedicationEntity> medications;
  const MedicationLoaded(this.medications);

  @override
  List<Object?> get props => [medications];
}

class MedicationAdded extends MedicationState {}

class MedicationUpdated extends MedicationState {}

class MedicationDeleted extends MedicationState {}

class MedicationError extends MedicationState {
  final String message;
  const MedicationError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class MedicationCubit extends Cubit<MedicationState> {
  final IMedicationRepository _medicationRepository;
  final _uuid = const Uuid();

  MedicationCubit(this._medicationRepository) : super(MedicationInitial());

  // جلب أدوية المريض
  void loadMedications(String patientId) {
    emit(MedicationLoading());
    _medicationRepository.getPatientMedications(patientId).listen(
      (medications) => emit(MedicationLoaded(medications)),
      onError: (e) => emit(const MedicationError('فشل في تحميل الأدوية')),
    );
  }

  // إضافة دواء
  // إضافة دواء
Future<void> addMedication({
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
  required List<String> times,
  required MedicationFrequency frequency,
  String? boxImageUrl,
  String? boxColorHex,
  String? pillShape,
  String? pillColorHex,
}) async {
  emit(MedicationLoading());
  try {
    final schedule = ScheduleEntity(
      id: _uuid.v4(),
      times: times,
      frequency: frequency,
      daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
      reminderMinutesBefore: 15,
    );

    final medication = await _medicationRepository.addMedication(
      patientId: patientId,
      name: name,
      nameAr: nameAr,
      dosage: dosage,
      unit: unit,
      form: form,
      instructions: instructions,
      startDate: startDate,
      endDate: endDate,
      createdBy: createdBy,
      schedules: [schedule],
      boxImageUrl: boxImageUrl,
      boxColorHex: boxColorHex,
      pillShape: pillShape,
      pillColorHex: pillColorHex,
    );

    // جدولة الإشعارات فوراً بعد الإضافة
    await NotificationScheduler.scheduleMedicationReminders(
      medicationId: medication.id,
      medicationName: medication.name,
      schedules: medication.schedules,
    );
    // جدولة الـ Alarm
await AlarmService.scheduleAlarms(
  medicationId: medication.id,
  medicationName: medication.name,
  schedules: medication.schedules,
);

    emit(MedicationAdded());
  } on ServerFailure catch (e) {
    emit(MedicationError(e.message));
  } catch (e) {
    emit(const MedicationError('فشل في إضافة الدواء'));
  }
}

// تعديل دواء
Future<void> updateMedication(MedicationEntity medication) async {
  emit(MedicationLoading());
  try {
    await _medicationRepository.updateMedication(medication);

    // إعادة جدولة الإشعارات بعد التعديل
    await NotificationScheduler.scheduleMedicationReminders(
      medicationId: medication.id,
      medicationName: medication.name,
      schedules: medication.schedules,
    );
    // إعادة جدولة الـ Alarm
await AlarmService.scheduleAlarms(
  medicationId: medication.id,
  medicationName: medication.name,
  schedules: medication.schedules,
);

    emit(MedicationUpdated());
  } on ServerFailure catch (e) {
    emit(MedicationError(e.message));
  } catch (e) {
    emit(const MedicationError('فشل في تحديث الدواء'));
  }
}

// حذف دواء
Future<void> deleteMedication(String medicationId) async {
  try {
    await _medicationRepository.deleteMedication(medicationId);

    // إلغاء إشعارات الدواء المحذوف
    await NotificationScheduler.cancelMedicationReminders(medicationId);
    // إلغاء الـ Alarm
    await AlarmService.cancelAlarms(medicationId);

    emit(MedicationDeleted());
  } catch (e) {
    emit(const MedicationError('فشل في حذف الدواء'));
  }
}
}
