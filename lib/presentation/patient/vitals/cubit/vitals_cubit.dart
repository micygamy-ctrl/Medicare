import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/vital_sign.dart';
import '../../../../domain/repositories/i_vitals_repository.dart';

abstract class VitalsState extends Equatable {
  const VitalsState();

  @override
  List<Object?> get props => [];
}

class VitalsInitial extends VitalsState {}

class VitalsLoading extends VitalsState {}

class VitalsLoaded extends VitalsState {
  final List<VitalSignEntity> vitals;
  final VitalSignEntity? latest;

  const VitalsLoaded({
    required this.vitals,
    this.latest,
  });

  @override
  List<Object?> get props => [vitals, latest];
}

class VitalsSyncing extends VitalsState {}

class VitalsError extends VitalsState {
  final String message;
  const VitalsError(this.message);

  @override
  List<Object?> get props => [message];
}

class VitalsCubit extends Cubit<VitalsState> {
  final IVitalsRepository _repository;
  StreamSubscription? _subscription;

  VitalsCubit(this._repository) : super(VitalsInitial());

  void loadPatientVitals(String patientId) {
    emit(VitalsLoading());
    _subscription?.cancel();
    _subscription = _repository.getPatientVitalsStream(patientId).listen(
      (vitals) {
        final latest = vitals.isNotEmpty ? vitals.first : null;
        emit(VitalsLoaded(vitals: vitals, latest: latest));
      },
      onError: (e) => emit(const VitalsError('فشل في تحميل قراءات المؤشرات الحيوية')),
    );
  }

  Future<void> syncSmartwatch(String patientId) async {
    emit(VitalsSyncing());
    try {
      await _repository.syncSmartwatchReading(patientId);
      // Wait slightly then reload stream
      await Future.delayed(const Duration(milliseconds: 500));
      loadPatientVitals(patientId);
    } catch (e) {
      emit(VitalsError(e.toString()));
    }
  }

  Future<void> addManualReading({
    required String patientId,
    required int systolicBP,
    required int diastolicBP,
    required int heartRate,
    required int spO2,
    required double temperature,
  }) async {
    try {
      await _repository.addVitalReading(
        patientId: patientId,
        systolicBP: systolicBP,
        diastolicBP: diastolicBP,
        heartRate: heartRate,
        spO2: spO2,
        temperature: temperature,
        source: VitalSource.manual,
      );
    } catch (e) {
      emit(VitalsError(e.toString()));
    }
  }

  Future<void> deleteReading(String vitalId) async {
    try {
      await _repository.deleteVitalReading(vitalId);
    } catch (e) {
      emit(const VitalsError('فشل في حذف القراءة'));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
