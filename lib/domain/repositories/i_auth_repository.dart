import '../entities/user.dart';

abstract class IAuthRepository {
  Stream<UserEntity?> get authStateChanges;

  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
    String? specialization,
    String? licenseNumber,
  });

  Future<UserEntity> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<UserEntity?> getCurrentUser();

  Future<void> updateFcmToken(String userId, String token);

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
  });
}