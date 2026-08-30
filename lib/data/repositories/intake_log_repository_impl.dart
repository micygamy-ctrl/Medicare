import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/intake_log.dart';
import '../../domain/repositories/i_intake_log_repository.dart';
import '../models/intake_log_model.dart';

class IntakeLogRepositoryImpl implements IIntakeLogRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  IntakeLogRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<IntakeLogEntity> createIntakeLog({
    required String medicationId,
    required String medicationName,
    required String patientId,
    required DateTime scheduledTime,
  }) async {
    try {
      final logId = _uuid.v4();
      final log = IntakeLogModel(
        id: logId,
        medicationId: medicationId,
        medicationName: medicationName,
        patientId: patientId,
        scheduledTime: scheduledTime,
        status: IntakeStatus.pending,
        snoozeCount: 0,
        source: 'patient',
      );

      await _firestore
          .collection('intakeLogs')
          .doc(logId)
          .set(log.toFirestore());

      return log;
    } catch (e) {
      throw const ServerFailure('فشل في إنشاء سجل الجرعة');
    }
  }

  @override
  Future<void> updateIntakeStatus({
    required String logId,
    required IntakeStatus status,
    String? note,
  }) async {
    try {
      await _firestore.collection('intakeLogs').doc(logId).update({
        'status': _statusToString(status),
        'respondedAt': Timestamp.now(),
        if (note != null) 'note': note,
      });
    } catch (e) {
      throw const ServerFailure('فشل في تحديث حالة الجرعة');
    }
  }

  @override
  Stream<List<IntakeLogEntity>> getTodayLogs(String patientId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('intakeLogs')
        .where('patientId', isEqualTo: patientId)
        .where('scheduledTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('scheduledTime',
            isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('scheduledTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IntakeLogModel.fromFirestore(doc))
            .toList());
  }

  @override
  Future<List<IntakeLogEntity>> getLogsByDateRange({
    required String patientId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('intakeLogs')
          .where('patientId', isEqualTo: patientId)
          .where('scheduledTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('scheduledTime',
              isLessThan: Timestamp.fromDate(endDate))
          .orderBy('scheduledTime')
          .get();

      return snapshot.docs
          .map((doc) => IntakeLogModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw const ServerFailure('فشل في جلب السجلات');
    }
  }

  @override
  Future<double> getAdherencePercentage({
    required String patientId,
    required int days,
  }) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final logs = await getLogsByDateRange(
        patientId: patientId,
        startDate: startDate,
        endDate: endDate,
      );

      if (logs.isEmpty) return 0.0;

      final takenCount =
          logs.where((log) => log.status == IntakeStatus.taken).length;

      return (takenCount / logs.length) * 100;
    } catch (e) {
      return 0.0;
    }
  }

  String _statusToString(IntakeStatus status) {
    switch (status) {
      case IntakeStatus.taken:
        return 'taken';
      case IntakeStatus.missed:
        return 'missed';
      case IntakeStatus.snoozed:
        return 'snoozed';
      default:
        return 'pending';
    }
  }
}