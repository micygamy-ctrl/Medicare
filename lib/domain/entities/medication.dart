enum MedicationForm { tablet, syrup, injection, capsule, drops, cream }

enum MedicationFrequency { daily, weekly, custom }

class MedicationEntity {
  final String id;
  final String patientId;
  final String name;
  final String nameAr;
  final String dosage;
  final String unit;
  final MedicationForm form;
  final String instructions;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final bool isDeleted;
  final String createdBy;
  final DateTime createdAt;
  final List<ScheduleEntity> schedules;

  // Visual Identifiers for Elderly & Illiterate Patients
  final String? boxImageUrl;
  final String? boxColorHex;
  final String? pillShape;
  final String? pillColorHex;

  const MedicationEntity({
    required this.id,
    required this.patientId,
    required this.name,
    required this.nameAr,
    required this.dosage,
    required this.unit,
    required this.form,
    required this.instructions,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.isDeleted,
    required this.createdBy,
    required this.createdAt,
    required this.schedules,
    this.boxImageUrl,
    this.boxColorHex,
    this.pillShape,
    this.pillColorHex,
  });

  MedicationEntity copyWith({
    String? name,
    String? nameAr,
    String? dosage,
    String? unit,
    MedicationForm? form,
    String? instructions,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    List<ScheduleEntity>? schedules,
    String? boxImageUrl,
    String? boxColorHex,
    String? pillShape,
    String? pillColorHex,
  }) {
    return MedicationEntity(
      id: id,
      patientId: patientId,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      dosage: dosage ?? this.dosage,
      unit: unit ?? this.unit,
      form: form ?? this.form,
      instructions: instructions ?? this.instructions,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted,
      createdBy: createdBy,
      createdAt: createdAt,
      schedules: schedules ?? this.schedules,
      boxImageUrl: boxImageUrl ?? this.boxImageUrl,
      boxColorHex: boxColorHex ?? this.boxColorHex,
      pillShape: pillShape ?? this.pillShape,
      pillColorHex: pillColorHex ?? this.pillColorHex,
    );
  }
}

class ScheduleEntity {
  final String id;
  final List<String> times;
  final MedicationFrequency frequency;
  final List<int> daysOfWeek;
  final int reminderMinutesBefore;

  const ScheduleEntity({
    required this.id,
    required this.times,
    required this.frequency,
    required this.daysOfWeek,
    required this.reminderMinutesBefore,
  });
}