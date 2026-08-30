import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../../../domain/entities/intake_log.dart';
import '../../../../domain/repositories/i_intake_log_repository.dart';
import '../../../../domain/repositories/i_medication_repository.dart';

abstract class ReminderState extends Equatable {
  const ReminderState();
  @override
  List<Object?> get props => [];
}

class ReminderInitial extends ReminderState {}
class ReminderLoading extends ReminderState {}

class ReminderLoaded extends ReminderState {
  final List<IntakeLogEntity> logs;
  const ReminderLoaded(this.logs);
  @override
  List<Object?> get props => [logs];
}

class ReminderError extends ReminderState {
  final String message;
  const ReminderError(this.message);
  @override
  List<Object?> get props => [message];
}

class ReminderCubit extends Cubit<ReminderState> {
  final IIntakeLogRepository _intakeLogRepository;
  final IMedicationRepository _medicationRepository;

  StreamSubscription? _logsSubscription;
  bool _isInitialized = false;

  ReminderCubit({
    required IIntakeLogRepository intakeLogRepository,
    required IMedicationRepository medicationRepository,
  })  : _intakeLogRepository = intakeLogRepository,
        _medicationRepository = medicationRepository,
        super(ReminderInitial());

  Future<void> loadTodayReminders(String patientId) async {
    // منع التحميل المزدوج
    if (_isInitialized) return;
    _isInitialized = true;

    emit(ReminderLoading());

    try {
      // إلغاء الـ subscription القديمة لو موجودة
      await _logsSubscription?.cancel();

      // إنشاء الـ logs الناقصة
      await _createMissingLogs(patientId);

      // الاستماع للـ stream
      _logsSubscription = _intakeLogRepository
          .getTodayLogs(patientId)
          .listen(
        (logs) {
          if (!isClosed) emit(ReminderLoaded(logs));
        },
        onError: (e) {
          if (!isClosed) {
            emit(const ReminderError('فشل في تحميل التذكيرات'));
          }
        },
      );
    } catch (e) {
      if (!isClosed) {
        emit(const ReminderError('فشل في تحميل التذكيرات'));
      }
    }
  }

  Future<void> _createMissingLogs(String patientId) async {
    try {
      final medications = await _medicationRepository
          .getPatientMedications(patientId)
          .first;

      final existingLogs = await _intakeLogRepository
          .getTodayLogs(patientId)
          .first;

      final now = DateTime.now();

      for (final medication in medications) {
        if (!medication.isActive) continue;

        for (final schedule in medication.schedules) {
          for (final time in schedule.times) {
            final parts = time.split(':');
            final hour = int.parse(parts[0]);
            final minute = int.parse(parts[1]);

            final scheduledTime = DateTime(
              now.year, now.month, now.day, hour, minute,
            );

            // تحقق دقيق من وجود الـ log
            final exists = existingLogs.any((log) =>
                log.medicationId == medication.id &&
                log.scheduledTime.hour == scheduledTime.hour &&
                log.scheduledTime.minute == scheduledTime.minute &&
                log.scheduledTime.day == scheduledTime.day);

            if (!exists) {
              await _intakeLogRepository.createIntakeLog(
                medicationId: medication.id,
                medicationName: medication.name,
                patientId: patientId,
                scheduledTime: scheduledTime,
              );
            }
          }
        }
      }
    } catch (e) {
      print('Error creating missing logs: $e');
    }
  }

  Future<void> markAsTaken(String logId) async {
    try {
      await _intakeLogRepository.updateIntakeStatus(
        logId: logId,
        status: IntakeStatus.taken,
      );
    } on ServerFailure catch (e) {
      emit(ReminderError(e.message));
    }
  }

  Future<void> markAsMissed(String logId) async {
    try {
      await _intakeLogRepository.updateIntakeStatus(
        logId: logId,
        status: IntakeStatus.missed,
      );
    } on ServerFailure catch (e) {
      emit(ReminderError(e.message));
    }
  }

  // إعادة التحميل لو محتاج
  Future<void> refresh(String patientId) async {
    _isInitialized = false;
    await loadTodayReminders(patientId);
  }

  @override
  Future<void> close() async {
    await _logsSubscription?.cancel();
    return super.close();
  }
}