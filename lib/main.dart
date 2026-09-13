import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/notification_scheduler.dart';
import 'domain/repositories/i_auth_repository.dart';
import 'domain/repositories/i_medication_repository.dart';
import 'firebase_options.dart';
import 'presentation/auth/cubit/auth_cubit.dart';
import 'presentation/auth/pages/login_page.dart';
import 'presentation/auth/pages/onboarding_page.dart';
import 'presentation/auth/pages/register_page.dart';
import 'presentation/auth/pages/splash_page.dart';
import 'presentation/caregiver/caregiver_main_page.dart';
import 'presentation/caregiver/pairing/pages/enter_pair_code_page.dart';
import 'presentation/doctor/doctor_main_page.dart';
import 'presentation/patient/home/patient_main_page.dart';
import 'presentation/patient/medications/cubit/medication_cubit.dart';
import 'presentation/patient/medications/pages/add_medication_page.dart';
import 'presentation/patient/pairing/pages/pair_code_page.dart';
import 'presentation/shared/cubit/locale_cubit.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'core/utils/background_service.dart';
import 'package:workmanager/workmanager.dart';
import 'core/utils/connectivity_service.dart';
import 'core/utils/alarm_service.dart';
import 'core/localization/app_language_cubit.dart';
import 'core/localization/app_strings.dart';
import 'l10n/app_localizations.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('Background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  final fcmToken = await FirebaseMessaging.instance.getToken();
  debugPrint('FCM Token: $fcmToken');

  await setupDependencies();
  await NotificationScheduler.initialize();
  await AlarmService.initialize();
  ConnectivityService().initialize();

  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

  await Workmanager().registerPeriodicTask(
    'medication-reminders',
    medicationReminderTask,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
    existingWorkPolicy: ExistingWorkPolicy.replace,
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MediCareApp());
}

class MediCareApp extends StatelessWidget {
  const MediCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthCubit(
            getIt<IAuthRepository>(),
            medicationRepository: getIt<IMedicationRepository>(),
          ),
        ),
        BlocProvider(
          create: (_) => LocaleCubit(),
        ),
        BlocProvider(
          create: (_) => AppLanguageCubit(),
        ),
      ],
      child: BlocBuilder<AppLanguageCubit, AppLanguageState>(
        builder: (context, langState) {
          AppStrings.setLanguage(langState.language);

          return MaterialApp(
            title: AppStrings.appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            locale: langState.locale,
            supportedLocales: const [
              Locale('ar'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              return Directionality(
                textDirection: langState.textDirection,
                child: child ?? const SizedBox.shrink(),
              );
            },
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashPage(),
              '/onboarding': (context) => const OnboardingPage(),
              '/login': (context) => const LoginPage(),
              '/register': (context) => const RegisterPage(),
              '/patient/main': (context) => const PatientMainPage(),
              '/caregiver/dashboard': (context) => const CaregiverMainPage(),
              '/doctor/dashboard': (context) => const DoctorMainPage(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/patient/pairing') {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => PairCodePage(
                    patientId: args['patientId'] as String,
                    patientName: args['patientName'] as String,
                  ),
                );
              }

              if (settings.name == '/caregiver/pairing') {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => EnterPairCodePage(
                    caregiverId: args['caregiverId'] as String,
                    caregiverName: args['caregiverName'] as String,
                  ),
                );
              }

              if (settings.name == '/patient/medications/add') {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (_) =>
                        MedicationCubit(getIt<IMedicationRepository>()),
                    child: AddMedicationPage(
                      patientId: args['patientId'] as String,
                      createdBy: args['createdBy'] as String? ?? '',
                    ),
                  ),
                );
              }

              return null;
            },
          );
        },
      ),
    );
  }
}
