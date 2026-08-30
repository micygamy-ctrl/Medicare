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

  DashboardCubit({
    required IPairingRepository pairingRepository,
    required IMedicationRepository medicationRepository,
    required IIntakeLogRepository intakeLogRepository,
  })  : _pairingRepository = pairingRepository,
        _medicationRepository = medicationRepository,
        _intakeLogRepository = intakeLogRepository,
        super(DashboardInitial());

  Future<void> loadDashboard(String caregiverId) async {
  emit(DashboardLoading());
  try {
    _pairingRepository.getCaregiverPatients(caregiverId).listen(
      (pairs) async {
        if (pairs.isEmpty) {
          emit(const DashboardLoaded([]));
          return;
        }

        // Parallel Reads — بدل Sequential
        final summaries = await Future.wait(
          pairs.map((pair) => _buildPatientSummary(pair)),
        );

        emit(DashboardLoaded(
          summaries.whereType<PatientSummary>().toList(),
        ));
      },
      onError: (e) =>
          emit(const DashboardError('فشل في تحميل البيانات')),
    );
  } catch (e) {
    emit(const DashboardError('فشل في تحميل البيانات'));
  }
}

Future<PatientSummary?> _buildPatientSummary(PairEntity pair) async {
  try {
    // Parallel — كل الـ reads في نفس الوقت
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
  } catch (e) {
    // لو فيه error في مريض واحد، مش هيوقف الباقين
    return PatientSummary(
      pair: pair,
      medications: const [],
      todayLogs: const [],
      adherencePercentage: 0,
    );
  }
}
}