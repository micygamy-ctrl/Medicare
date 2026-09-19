import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/intake_log.dart';
import '../../../../domain/entities/medication.dart';
import '../../../../domain/entities/pair.dart';
import '../../../../domain/repositories/i_intake_log_repository.dart';
import '../../../../domain/repositories/i_medication_repository.dart';
import '../../../../domain/repositories/i_pairing_repository.dart';

// Patient Summary Model
class PatientSummary {
  final PairEntity pair;
  final List<MedicationEntity> medications;
  final List<IntakeLogEntity> todayLogs;
  final double adherencePercentage;

  const PatientSummary({
    required this.pair,
    required this.medications,
    required this.todayLogs,
    required this.adherencePercentage,
  });

  int get takenToday =>
      todayLogs.where((l) => l.status == IntakeStatus.taken).length;

  int get missedToday =>
      todayLogs.where((l) => l.status == IntakeStatus.missed).length;

  int get pendingToday =>
      todayLogs.where((l) => l.status == IntakeStatus.pending).length;
}

// States
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<PatientSummary> patients;
  const DashboardLoaded(this.patients);

  @override
  List<Object?> get props => [patients];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class DashboardCubit extends Cubit<DashboardState> {
  final IPairingRepository _pairingRepository;
  final IMedicationRepository _medicationRepository;
  final IIntakeLogRepository _intakeLogRepository;
  StreamSubscription? _patientsSubscription;
  int _loadGeneration = 0;

  DashboardCubit({
    required IPairingRepository pairingRepository,
    required IMedicationRepository medicationRepository,
    required IIntakeLogRepository intakeLogRepository,
  })  : _pairingRepository = pairingRepository,
        _medicationRepository = medicationRepository,
        _intakeLogRepository = intakeLogRepository,
        super(DashboardInitial());

  Future<void> loadDashboard(String caregiverId) async {
    final loadGeneration = ++_loadGeneration;
    emit(DashboardLoading());
    await _patientsSubscription?.cancel();

    try {
      _patientsSubscription = _pairingRepository
          .getCaregiverPatients(caregiverId)
          .listen(
        (pairs) async {
          try {
            if (loadGeneration != _loadGeneration || isClosed) return;

            if (pairs.isEmpty) {
              emit(const DashboardLoaded([]));
              return;
            }

            final summaries = await Future.wait(
              pairs.map(_buildPatientSummary),
            );

            if (loadGeneration == _loadGeneration && !isClosed) {
              emit(DashboardLoaded(summaries));
            }
          } catch (e) {
            if (loadGeneration == _loadGeneration && !isClosed) {
              emit(const DashboardError('فشل في تحميل بيانات المرضى'));
            }
          }
        },
        onError: (e) {
          if (loadGeneration == _loadGeneration && !isClosed) {
            emit(const DashboardError('فشل في تحميل البيانات'));
          }
        },
      );
    } catch (e) {
      if (!isClosed) {
        emit(const DashboardError('فشل في تحميل البيانات'));
      }
    }
  }

  Future<PatientSummary> _buildPatientSummary(PairEntity pair) async {
    final results = await Future.wait([
      _medicationRepository
          .getPatientMedications(pair.patientId)
          .first,
      _intakeLogRepository
          .getTodayLogs(pair.patientId)
          .first,
      _intakeLogRepository.getAdherencePercentage(
        patientId: pair.patientId,
        days: 7,
      ),
    ]);

    return PatientSummary(
      pair: pair,
      medications: results[0] as List<MedicationEntity>,
      todayLogs: results[1] as List<IntakeLogEntity>,
      adherencePercentage: results[2] as double,
    );
  }

  @override
  Future<void> close() async {
    _loadGeneration++;
    await _patientsSubscription?.cancel();
    return super.close();
  }
}