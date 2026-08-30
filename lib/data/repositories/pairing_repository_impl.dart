import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/pair.dart';
import '../../domain/repositories/i_pairing_repository.dart';
import '../models/pair_model.dart';

class PairingRepositoryImpl implements IPairingRepository {
  final FirebaseFirestore _firestore;

  PairingRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // توليد كود عشوائي 6 أرقام
  String _generateCode() {
    const chars = '0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String code = '';
    int seed = random;
    for (int i = 0; i < 6; i++) {
      seed = (seed * 1664525 + 1013904223) & 0xFFFFFFFF;
      code += chars[seed % chars.length];
    }
    return code;
  }

  @override
  Future<String> generatePairingCode(String patientId) async {
    try {
      // احذف الكود القديم لو موجود
      final oldCodes = await _firestore
          .collection('pairingCodes')
          .where('patientId', isEqualTo: patientId)
          .where('isUsed', isEqualTo: false)
          .get();

      for (final doc in oldCodes.docs) {
        await doc.reference.delete();
      }

      // ولّد كود جديد
      String code = _generateCode();

      // تأكد إن الكود مش موجود
      var existing =
          await _firestore.collection('pairingCodes').doc(code).get();
      while (existing.exists) {
        code = _generateCode();
        existing =
            await _firestore.collection('pairingCodes').doc(code).get();
      }

      // احفظ الكود
      await _firestore.collection('pairingCodes').doc(code).set({
        'code': code,
        'patientId': patientId,
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(hours: 24)),
        ),
        'isUsed': false,
        'createdAt': Timestamp.now(),
      });

      return code;
    } catch (e) {
      throw const ServerFailure('فشل في توليد الكود');
    }
  }

  @override
  Future<PairEntity> pairWithPatient({
    required String code,
    required String caregiverId,
    required String caregiverName,
  }) async {
    try {
      // جلب الكود
      final codeDoc =
          await _firestore.collection('pairingCodes').doc(code).get();

      if (!codeDoc.exists) {
        throw const ValidationFailure('الكود غير صحيح');
      }

      final codeData = codeDoc.data() as Map<String, dynamic>;

      // تحقق من انتهاء الصلاحية
      final expiresAt = (codeData['expiresAt'] as Timestamp).toDate();
      if (DateTime.now().isAfter(expiresAt)) {
        throw const ValidationFailure('انتهت صلاحية الكود');
      }

      // تحقق إن الكود لم يستخدم
      if (codeData['isUsed'] == true) {
        throw const ValidationFailure('تم استخدام هذا الكود من قبل');
      }

      final patientId = codeData['patientId'] as String;

      // تحقق إن مقدم الرعاية مش هو نفس المريض
      if (patientId == caregiverId) {
        throw const ValidationFailure('لا يمكنك ربط حسابك بنفسك');
      }

      // جلب بيانات المريض
      final patientDoc =
          await _firestore.collection('users').doc(patientId).get();
      final patientName =
          (patientDoc.data() as Map<String, dynamic>)['displayName'] ?? '';

      // إنشاء الـ pair
      final pairId = '${caregiverId}_$patientId';
      final pair = PairModel(
        id: pairId,
        patientId: patientId,
        caregiverId: caregiverId,
        patientName: patientName,
        caregiverName: caregiverName,
        status: PairStatus.active,
        pairedAt: DateTime.now(),
      );

      // حفظ الـ pair في Firestore
      await _firestore
          .collection('pairs')
          .doc(pairId)
          .set(pair.toFirestore());

      // تحديث الكود كـ مستخدم
      await _firestore
          .collection('pairingCodes')
          .doc(code)
          .update({'isUsed': true});

      return pair;
    } on ValidationFailure {
      rethrow;
    } catch (e) {
      throw const ServerFailure('فشل في ربط الحساب');
    }
  }

  @override
  Future<PairEntity?> getPatientPair(String patientId) async {
    try {
      final query = await _firestore
          .collection('pairs')
          .where('patientId', isEqualTo: patientId)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      return PairModel.fromFirestore(query.docs.first);
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<List<PairEntity>> getCaregiverPatients(String caregiverId) {
    return _firestore
        .collection('pairs')
        .where('caregiverId', isEqualTo: caregiverId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PairModel.fromFirestore(doc))
            .toList());
  }

  @override
  Future<void> revokePair(String pairId) async {
    await _firestore.collection('pairs').doc(pairId).update({
      'status': 'revoked',
      'revokedAt': Timestamp.now(),
    });
  }
}