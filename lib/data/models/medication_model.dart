import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/medication.dart';

class ScheduleModel extends ScheduleEntity {
  const ScheduleModel({
    required super.id,
    required super.times,
    required super.frequency,
    required super.daysOfWeek,
    required super.reminderMinutesBefore,
  });

  factory ScheduleModel.fromMap(Map<String, dynamic> data, String id) {
    return ScheduleModel(
      id: id,
      times: List<String>.from(data['times'] ?? []),
      frequency: _frequencyFromString(data['frequency']),
      daysOfWeek: List<int>.from(data['daysOfWeek'] ?? []),
      reminderMinutesBefore: data['reminderMinutesBefore'] ?? 15,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'times': times,
      'frequency': _frequencyToString(frequency),
      'daysOfWeek': daysOfWeek,
      'reminderMinutesBefore': reminderMinutesBefore,
    };
  }

  static MedicationFrequency _frequencyFromString(String? value) {
    switch (value) {
      case 'weekly':
        return MedicationFrequency.weekly;
      case 'custom':
        return MedicationFrequency.custom;
      default:
        return MedicationFrequency.daily;
    }
  }

  static String _frequencyToString(MedicationFrequency freq) {
    switch (freq) {
      case MedicationFrequency.weekly:
        return 'weekly';
      case MedicationFrequency.custom:
        return 'custom';
      default:
        return 'daily';
    }
  }
}

class MedicationModel extends MedicationEntity {
  const MedicationModel({
    required super.id,
    required super.patientId,
    required super.name,
    required super.nameAr,
    required super.dosage,
    required super.unit,
    required super.form,
    required super.instructions,
    required super.startDate,
    super.endDate,
    required super.isActive,
    required super.isDeleted,
    required super.createdBy,
    required super.createdAt,
    required super.schedules,
    super.boxImageUrl,
    super.boxColorHex,
    super.pillShape,
    super.pillColorHex,
  });

  factory MedicationModel.fromFirestore(
    DocumentSnapshot doc,
    List<ScheduleModel> schedules,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    return MedicationModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      name: data['name'] ?? '',
      nameAr: data['nameAr'] ?? '',
      dosage: data['dosage'] ?? '',
      unit: data['unit'] ?? '',
      form: _formFromString(data['form']),
      instructions: data['instructions'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] ?? true,
      isDeleted: data['isDeleted'] ?? false,
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      schedules: schedules,
      boxImageUrl: data['boxImageUrl'],
      boxColorHex: data['boxColorHex'],
      pillShape: data['pillShape'],
      pillColorHex: data['pillColorHex'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'name': name,
      'nameAr': nameAr,
      'dosage': dosage,
      'unit': unit,
      'form': _formToString(form),
      'instructions': instructions,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'isActive': isActive,
      'isDeleted': isDeleted,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'boxImageUrl': boxImageUrl,
      'boxColorHex': boxColorHex,
      'pillShape': pillShape,
      'pillColorHex': pillColorHex,
    };
  }

  static MedicationForm _formFromString(String? value) {
    switch (value) {
      case 'syrup':
        return MedicationForm.syrup;
      case 'injection':
        return MedicationForm.injection;
      case 'capsule':
        return MedicationForm.capsule;
      case 'drops':
        return MedicationForm.drops;
      case 'cream':
        return MedicationForm.cream;
      default:
        return MedicationForm.tablet;
    }
  }

  static String _formToString(MedicationForm form) {
    switch (form) {
      case MedicationForm.syrup:
        return 'syrup';
      case MedicationForm.injection:
        return 'injection';
      case MedicationForm.capsule:
        return 'capsule';
      case MedicationForm.drops:
        return 'drops';
      case MedicationForm.cream:
        return 'cream';
      default:
        return 'tablet';
    }
  }
}