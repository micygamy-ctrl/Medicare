enum VitalStatus { normal, warning, critical }

enum VitalSource { smartwatch, bluetoothSensor, healthKit, manual }

class VitalSignEntity {
  final String id;
  final String patientId;
  final int systolicBP; // mmHg (e.g. 120)
  final int diastolicBP; // mmHg (e.g. 80)
  final int heartRate; // bpm (e.g. 72)
  final int spO2; // % (e.g. 98)
  final double temperature; // °C (e.g. 36.8)
  final VitalSource source;
  final VitalStatus status;
  final DateTime timestamp;

  const VitalSignEntity({
    required this.id,
    required this.patientId,
    required this.systolicBP,
    required this.diastolicBP,
    required this.heartRate,
    required this.spO2,
    required this.temperature,
    required this.source,
    required this.status,
    required this.timestamp,
  });

  /// Evaluates clinical status based on standard medical threshold rules
  static VitalStatus calculateStatus({
    required int systolic,
    required int diastolic,
    required int heartRate,
    required int spO2,
  }) {
    if (systolic >= 145 ||
        diastolic >= 95 ||
        systolic <= 85 ||
        heartRate >= 120 ||
        heartRate <= 45 ||
        spO2 <= 90) {
      return VitalStatus.critical;
    } else if (systolic >= 135 ||
        diastolic >= 88 ||
        heartRate >= 100 ||
        spO2 <= 94) {
      return VitalStatus.warning;
    }
    return VitalStatus.normal;
  }
}
