import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../../../domain/entities/pair.dart';
import '../../../../domain/repositories/i_pairing_repository.dart';

// States
abstract class PairingState extends Equatable {
  const PairingState();

  @override
  List<Object?> get props => [];
}

class PairingInitial extends PairingState {}

class PairingLoading extends PairingState {}

class PairingCodeGenerated extends PairingState {
  final String code;
  const PairingCodeGenerated(this.code);

  @override
  List<Object?> get props => [code];
}

class PairingSuccess extends PairingState {
  final PairEntity pair;
  const PairingSuccess(this.pair);

  @override
  List<Object?> get props => [pair];
}

class PairingAlreadyPaired extends PairingState {
  final PairEntity pair;
  const PairingAlreadyPaired(this.pair);

  @override
  List<Object?> get props => [pair];
}

class PairingRevoked extends PairingState {}

class PairingError extends PairingState {
  final String message;
  const PairingError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class PairingCubit extends Cubit<PairingState> {
  final IPairingRepository _pairingRepository;

  PairingCubit(this._pairingRepository) : super(PairingInitial());

  // المريض يولّد كود
  Future<void> generateCode(String patientId) async {
    emit(PairingLoading());
    try {
      final code = await _pairingRepository.generatePairingCode(patientId);
      emit(PairingCodeGenerated(code));
    } on ServerFailure catch (e) {
      emit(PairingError(e.message));
    } catch (e) {
      emit(const PairingError('فشل في توليد الكود'));
    }
  }

  // تحقق من وجود pair حالي
  Future<void> checkExistingPair(String patientId) async {
    emit(PairingLoading());
    try {
      final pair = await _pairingRepository.getPatientPair(patientId);
      if (pair != null) {
        emit(PairingAlreadyPaired(pair));
      } else {
        emit(PairingInitial());
      }
    } catch (e) {
      emit(PairingInitial());
    }
  }

  // مقدم الرعاية يدخل الكود
  Future<void> pairWithCode({
    required String code,
    required String caregiverId,
    required String caregiverName,
  }) async {
    emit(PairingLoading());
    try {
      final pair = await _pairingRepository.pairWithPatient(
        code: code,
        caregiverId: caregiverId,
        caregiverName: caregiverName,
      );
      emit(PairingSuccess(pair));
    } on ValidationFailure catch (e) {
      emit(PairingError(e.message));
    } on ServerFailure catch (e) {
      emit(PairingError(e.message));
    } catch (e) {
      emit(const PairingError('فشل في ربط الحساب'));
    }
  }

  // إلغاء الارتباط
  Future<void> revokePair(String pairId) async {
    emit(PairingLoading());
    try {
      await _pairingRepository.revokePair(pairId);
      emit(PairingRevoked());
    } catch (e) {
      emit(const PairingError('فشل في إلغاء الارتباط'));
    }
  }
}