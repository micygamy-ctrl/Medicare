import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/intake_log_repository_impl.dart';
import '../../data/repositories/medication_repository_impl.dart';
import '../../data/repositories/pairing_repository_impl.dart';
import '../../data/repositories/lab_report_repository_impl.dart';
import '../../data/repositories/vitals_repository_impl.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_intake_log_repository.dart';
import '../../domain/repositories/i_lab_report_repository.dart';
import '../../domain/repositories/i_medication_repository.dart';
import '../../domain/repositories/i_pairing_repository.dart';
import '../../domain/repositories/i_vitals_repository.dart';
import '../services/ai_lab_analysis_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // تفعيل Firestore Offline Persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Firebase
  getIt.registerLazySingleton<FirebaseAuth>(
    () => FirebaseAuth.instance,
  );
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // Repositories
  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(
      auth: getIt<FirebaseAuth>(),
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  getIt.registerLazySingleton<IPairingRepository>(
    () => PairingRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  getIt.registerLazySingleton<IMedicationRepository>(
    () => MedicationRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  getIt.registerLazySingleton<IIntakeLogRepository>(
    () => IntakeLogRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  // Services
  getIt.registerLazySingleton<AILabAnalysisService>(
    () => AILabAnalysisService(),
  );

  // Lab Report Repository
  getIt.registerLazySingleton<ILabReportRepository>(
    () => LabReportRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
      aiService: getIt<AILabAnalysisService>(),
    ),
  );

  // Vitals Repository
  getIt.registerLazySingleton<IVitalsRepository>(
    () => VitalsRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
    ),
  );
}