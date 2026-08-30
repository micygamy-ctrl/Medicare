// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Med Care';

  @override
  String get appTagline => 'Healthcare & Medication Monitoring';

  @override
  String get login => 'Login';

  @override
  String get register => 'Create New Account';

  @override
  String get email => 'Email Address';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get selectRole => 'Select Account Type';

  @override
  String get patient => 'Patient';

  @override
  String get patientSubtitle => 'Track medications & vitals';

  @override
  String get caregiver => 'Caregiver';

  @override
  String get caregiverSubtitle => 'Monitor a patient\'s adherence';

  @override
  String get doctor => 'Doctor / Physician';

  @override
  String get doctorSubtitle => 'Monitor patients & update prescriptions';

  @override
  String get specialization => 'Medical Specialization';

  @override
  String get licenseNumber => 'Medical License Number';

  @override
  String get enterSpecialization => 'Enter your specialization';

  @override
  String get enterLicenseNumber => 'Enter your medical license ID';

  @override
  String get disclaimerTitle => 'Medical Disclaimer & Terms';

  @override
  String get disclaimerAccept => 'I Agree & Accept Terms';

  @override
  String get doctorDashboard => 'Doctor Dashboard';

  @override
  String get myPatients => 'My Patients';

  @override
  String get addPatient => 'Link New Patient';

  @override
  String get adherenceRate => 'Medication Adherence Rate';

  @override
  String get missedDosesAlert => 'Missed Doses Alert';

  @override
  String get viewHealthProfile => 'View Medical Record';

  @override
  String get prescriptions => 'Prescriptions & Medications';

  @override
  String get addPrescription => 'Add Prescription / Medication';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';
}
