import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/utils/analytics_service.dart';
import '../../../core/utils/notification_scheduler.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/i_auth_repository.dart';
import '../../../domain/repositories/i_medication_repository.dart';
import '../../../core/error/failures.dart';
import '../../../core/utils/alarm_service.dart';

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class AuthCubit extends Cubit<AuthState> {
  final IAuthRepository _authRepository;
  final IMedicationRepository? _medicationRepository;

  AuthCubit(
    this._authRepository, {
    IMedicationRepository? medicationRepository,
  })  : _medicationRepository = medicationRepository,
        super(AuthInitial());

  Future<void> checkAuthState() async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
        // جدولة الإشعارات لما التطبيق يفتح
        if (user.role == UserRole.patient) {
          _scheduleNotifications(user.uid);
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _scheduleNotifications(String patientId) async {
  try {
    if (_medicationRepository == null) return;
    final medications = await _medicationRepository!
        .getPatientMedications(patientId)
        .first;

    // جدولة الـ Notifications والـ Alarms
    await NotificationScheduler.scheduleAllMedications(medications);
    await AlarmService.scheduleAllMedications(medications);

    print('✅ Scheduled ${medications.length} medications');
  } catch (e) {
    print('Error scheduling: $e');
  }
}

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signIn(
        email: email,
        password: password,
      );
      await AnalyticsService.logLogin(
        user.role == UserRole.patient ? 'patient' : 'caregiver',
      );
      emit(AuthAuthenticated(user));
      if (user.role == UserRole.patient) {
        _scheduleNotifications(user.uid);
      }
    } on AuthFailure catch (e) {
      emit(AuthError(e.message));
    } on ServerFailure catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('حدث خطأ، حاول مرة أخرى'));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
    String? specialization,
    String? licenseNumber,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signUp(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
        specialization: specialization,
        licenseNumber: licenseNumber,
      );
      await AnalyticsService.logSignUp(
        role == UserRole.patient
            ? 'patient'
            : role == UserRole.doctor
                ? 'doctor'
                : 'caregiver',
      );
      emit(AuthAuthenticated(user));
    } on AuthFailure catch (e) {
      emit(AuthError(e.message));
    } on ServerFailure catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('حدث خطأ، حاول مرة أخرى'));
    }
  }

  Future<void> signOut() async {
    await NotificationScheduler.cancelAll();
    await _authRepository.signOut();
    emit(AuthUnauthenticated());
  }

  Future<void> updateProfile({
    required String userId,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
    BloodType? bloodType,
    List<String>? chronicDiseases,
    List<String>? allergies,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? doctorName,
    String? notes,
  }) async {
    try {
      await _authRepository.updateProfile(
        userId: userId,
        phone: phone,
        dateOfBirth: dateOfBirth,
        gender: gender,
        bloodType: bloodType,
        chronicDiseases: chronicDiseases,
        allergies: allergies,
        emergencyContactName: emergencyContactName,
        emergencyContactPhone: emergencyContactPhone,
        doctorName: doctorName,
        notes: notes,
      );
      await checkAuthState();
    } catch (e) {
      emit(const AuthError('فشل في تحديث البيانات'));
    }
  }
}