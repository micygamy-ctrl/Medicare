import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Auth Events
  static Future<void> logLogin(String role) async {
    await _analytics.logLogin(loginMethod: role);
  }

  static Future<void> logSignUp(String role) async {
    await _analytics.logSignUp(signUpMethod: role);
  }

  // Medication Events
  static Future<void> logMedicationAdded(String form) async {
    await _analytics.logEvent(
      name: 'medication_added',
      parameters: {'form': form},
    );
  }

  static Future<void> logMedicationTaken(String medicationId) async {
    await _analytics.logEvent(
      name: 'medication_taken',
      parameters: {'medication_id': medicationId},
    );
  }

  static Future<void> logMedicationMissed(String medicationId) async {
    await _analytics.logEvent(
      name: 'medication_missed',
      parameters: {'medication_id': medicationId},
    );
  }

  // Pairing Events
  static Future<void> logPairingCreated() async {
    await _analytics.logEvent(name: 'pairing_created');
  }

  // Screen Events
  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }
}