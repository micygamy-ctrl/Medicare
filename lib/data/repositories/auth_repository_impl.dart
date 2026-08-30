import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../models/user_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class AuthRepositoryImpl implements IAuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  @override
  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await getCurrentUser();
    });
  }

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
    String? specialization,
    String? licenseNumber,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel(
        uid: credential.user!.uid,
        displayName: displayName,
        email: email,
        role: role,
        locale: AppLocale.ar,
        createdAt: DateTime.now(),
        specialization: specialization,
        licenseNumber: licenseNumber,
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toFirestore());

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthFailureHandler.fromCode(e.code);
    } catch (e) {
      throw const ServerFailure('حدث خطأ، حاول مرة أخرى');
    }
  }

  @override
  @override
Future<UserEntity> signIn({
  required String email,
  required String password,
}) async {
  try {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = await getCurrentUser();
    if (user == null) throw const AuthFailure('حدث خطأ في تسجيل الدخول');
    
    // تحديث الـ FCM Token
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await updateFcmToken(user.uid, fcmToken);
      }
    } catch (e) {
      print('FCM token update error: $e');
    }
    
    return user;
  } on FirebaseAuthException catch (e) {
    throw AuthFailureHandler.fromCode(e.code);
  } on AuthFailure {
    rethrow;
  } catch (e) {
    throw const ServerFailure('حدث خطأ، حاول مرة أخرى');
  }
}

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateFcmToken(String userId, String token) async {
    await _firestore.collection('users').doc(userId).update({
      'fcmToken': token,
    });
  }
  @override
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
      final Map<String, dynamic> updates = {};
      if (phone != null) updates['phone'] = phone;
      if (dateOfBirth != null)
        updates['dateOfBirth'] = Timestamp.fromDate(dateOfBirth);
      if (gender != null) updates['gender'] = gender;
      if (bloodType != null)
        updates['bloodType'] = _bloodTypeToString(bloodType);
      if (chronicDiseases != null)
        updates['chronicDiseases'] = chronicDiseases;
      if (allergies != null) updates['allergies'] = allergies;
      if (emergencyContactName != null)
        updates['emergencyContactName'] = emergencyContactName;
      if (emergencyContactPhone != null)
        updates['emergencyContactPhone'] = emergencyContactPhone;
      if (doctorName != null) updates['doctorName'] = doctorName;
      if (notes != null) updates['notes'] = notes;

      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      throw const ServerFailure('فشل في تحديث البيانات');
    }
  }

  String? _bloodTypeToString(BloodType? type) {
    switch (type) {
      case BloodType.aPositive: return 'A+';
      case BloodType.aNegative: return 'A-';
      case BloodType.bPositive: return 'B+';
      case BloodType.bNegative: return 'B-';
      case BloodType.abPositive: return 'AB+';
      case BloodType.abNegative: return 'AB-';
      case BloodType.oPositive: return 'O+';
      case BloodType.oNegative: return 'O-';
      default: return null;
    }
  }
}