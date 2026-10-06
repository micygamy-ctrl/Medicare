import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.displayName,
    required super.email,
    super.phone,
    required super.role,
    required super.locale,
    super.photoUrl,
    super.fcmToken,
    required super.createdAt,
    super.specialization,
    super.licenseNumber,
    super.assignedPatients = const [],
    super.dateOfBirth,
    super.gender,
    super.bloodType,
    super.chronicDiseases = const [],
    super.allergies = const [],
    super.emergencyContactName,
    super.emergencyContactPhone,
    super.doctorName,
    super.notes,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    UserRole role;
    if (data['role'] == 'doctor') {
      role = UserRole.doctor;
    } else if (data['role'] == 'caregiver') {
      role = UserRole.caregiver;
    } else {
      role = UserRole.patient;
    }

    DateTime _parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.now();
    }

    return UserModel(
      uid: doc.id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      role: role,
      locale: data['locale'] == 'en' ? AppLocale.en : AppLocale.ar,
      photoUrl: data['photoUrl'],
      fcmToken: data['fcmToken'],
      createdAt: data['createdAt'] != null ? _parseDate(data['createdAt']) : DateTime.now(),
      specialization: data['specialization'],
      licenseNumber: data['licenseNumber'],
      assignedPatients: List<String>.from(data['assignedPatients'] ?? []),
      dateOfBirth: data['dateOfBirth'] != null
          ? _parseDate(data['dateOfBirth'])
          : null,
      gender: data['gender'],
      bloodType: _bloodTypeFromString(data['bloodType']),
      chronicDiseases:
          List<String>.from(data['chronicDiseases'] ?? []),
      allergies: List<String>.from(data['allergies'] ?? []),
      emergencyContactName: data['emergencyContactName'],
      emergencyContactPhone: data['emergencyContactPhone'],
      doctorName: data['doctorName'],
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    String roleStr = 'patient';
    if (role == UserRole.doctor) {
      roleStr = 'doctor';
    } else if (role == UserRole.caregiver) {
      roleStr = 'caregiver';
    }

    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'phone': phone,
      'role': roleStr,
      'locale': locale == AppLocale.en ? 'en' : 'ar',
      'photoUrl': photoUrl,
      'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
      'isDeleted': false,
      'isApproved': role == UserRole.doctor ? true : true,
      'specialization': specialization,
      'licenseNumber': licenseNumber,
      'assignedPatients': assignedPatients,
      'dateOfBirth':
          dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'gender': gender,
      'bloodType': _bloodTypeToString(bloodType),
      'chronicDiseases': chronicDiseases,
      'allergies': allergies,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'doctorName': doctorName,
      'notes': notes,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      displayName: entity.displayName,
      email: entity.email,
      phone: entity.phone,
      role: entity.role,
      locale: entity.locale,
      photoUrl: entity.photoUrl,
      fcmToken: entity.fcmToken,
      createdAt: entity.createdAt,
      specialization: entity.specialization,
      licenseNumber: entity.licenseNumber,
      assignedPatients: entity.assignedPatients,
      dateOfBirth: entity.dateOfBirth,
      gender: entity.gender,
      bloodType: entity.bloodType,
      chronicDiseases: entity.chronicDiseases,
      allergies: entity.allergies,
      emergencyContactName: entity.emergencyContactName,
      emergencyContactPhone: entity.emergencyContactPhone,
      doctorName: entity.doctorName,
      notes: entity.notes,
    );
  }

  static BloodType? _bloodTypeFromString(String? value) {
    switch (value) {
      case 'A+': return BloodType.aPositive;
      case 'A-': return BloodType.aNegative;
      case 'B+': return BloodType.bPositive;
      case 'B-': return BloodType.bNegative;
      case 'AB+': return BloodType.abPositive;
      case 'AB-': return BloodType.abNegative;
      case 'O+': return BloodType.oPositive;
      case 'O-': return BloodType.oNegative;
      default: return BloodType.unknown;
    }
  }

  static String? _bloodTypeToString(BloodType? type) {
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