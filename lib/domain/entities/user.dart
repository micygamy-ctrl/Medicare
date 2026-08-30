enum UserRole { patient, caregiver, doctor }

enum AppLocale { ar, en }

enum BloodType { aPositive, aNegative, bPositive, bNegative, abPositive, abNegative, oPositive, oNegative, unknown }

class UserEntity {
  final String uid;
  final String displayName;
  final String email;
  final String? phone;
  final UserRole role;
  final AppLocale locale;
  final String? photoUrl;
  final String? fcmToken;
  final DateTime createdAt;

  // Doctor Specific Profile
  final String? specialization;
  final String? licenseNumber;
  final List<String> assignedPatients;

  // Patient Medical Profile
  final DateTime? dateOfBirth;
  final String? gender;
  final BloodType? bloodType;
  final List<String> chronicDiseases;
  final List<String> allergies;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? doctorName;
  final String? notes;

  const UserEntity({
    required this.uid,
    required this.displayName,
    required this.email,
    this.phone,
    required this.role,
    required this.locale,
    this.photoUrl,
    this.fcmToken,
    required this.createdAt,
    this.specialization,
    this.licenseNumber,
    this.assignedPatients = const [],
    this.dateOfBirth,
    this.gender,
    this.bloodType,
    this.chronicDiseases = const [],
    this.allergies = const [],
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.doctorName,
    this.notes,
  });

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  UserEntity copyWith({
    String? displayName,
    String? phone,
    UserRole? role,
    AppLocale? locale,
    String? photoUrl,
    String? fcmToken,
    String? specialization,
    String? licenseNumber,
    List<String>? assignedPatients,
    DateTime? dateOfBirth,
    String? gender,
    BloodType? bloodType,
    List<String>? chronicDiseases,
    List<String>? allergies,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? doctorName,
    String? notes,
  }) {
    return UserEntity(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      locale: locale ?? this.locale,
      photoUrl: photoUrl ?? this.photoUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
      specialization: specialization ?? this.specialization,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      assignedPatients: assignedPatients ?? this.assignedPatients,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
      allergies: allergies ?? this.allergies,
      emergencyContactName:
          emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      doctorName: doctorName ?? this.doctorName,
      notes: notes ?? this.notes,
    );
  }
}