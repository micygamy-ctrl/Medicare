class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String roleSelection = '/role-selection';

  // Patient
  static const String patientHome = '/patient/home';
  static const String medications = '/patient/medications';
  static const String addMedication = '/patient/medications/add';
  static const String reminders = '/patient/reminders';
  static const String patientPairing = '/patient/pairing';

  // Caregiver
  static const String caregiverDashboard = '/caregiver/dashboard';
  static const String patientDetail = '/caregiver/patient/:patientId';
  static const String caregiverPairing = '/caregiver/pairing';
}