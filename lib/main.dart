import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/constants/app_routes.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/notification_scheduler.dart';
import 'domain/repositories/i_auth_repository.dart';
import 'domain/repositories/i_intake_log_repository.dart';
import 'domain/repositories/i_medication_repository.dart';
import 'domain/repositories/i_pairing_repository.dart';
import 'domain/entities/user.dart';
import 'firebase_options.dart';
import 'presentation/auth/cubit/auth_cubit.dart';
import 'presentation/auth/pages/login_page.dart';
import 'presentation/auth/pages/onboarding_page.dart';
import 'presentation/auth/pages/register_page.dart';
import 'presentation/auth/pages/splash_page.dart';
import 'presentation/caregiver/caregiver_main_page.dart';
import 'presentation/caregiver/pairing/pages/enter_pair_code_page.dart';
import 'presentation/doctor/doctor_main_page.dart';
import 'presentation/doctor/patient_detail/pages/doctor_patient_detail_page.dart';
import 'presentation/patient/home/patient_main_page.dart';
import 'presentation/patient/medications/cubit/medication_cubit.dart';
import 'presentation/patient/medications/pages/add_medication_page.dart';
import 'presentation/patient/medications/pages/medication_list_page.dart';
import 'presentation/patient/pairing/cubit/pairing_cubit.dart';
import 'presentation/patient/pairing/pages/pair_code_page.dart';
import 'presentation/patient/reminders/cubit/reminder_cubit.dart';
import 'presentation/patient/reminders/pages/today_reminders_page.dart';
import 'presentation/shared/cubit/locale_cubit.dart';
import 'presentation/shared/pages/unknown_route_page.dart';
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
            initialRoute: AppRoutes.splash,
            onGenerateRoute: _onGenerateRoute,
          );
        },
      ),
    );
  }
}

Route<dynamic> _onGenerateRoute(RouteSettings settings) {
  final name = settings.name;
  final args = _routeArguments(settings);

  switch (name) {
    case AppRoutes.splash:
      return _pageRoute(settings, const SplashPage());
    case AppRoutes.roleSelection:
      return _pageRoute(settings, const OnboardingPage());
    case AppRoutes.login:
      return _pageRoute(settings, const LoginPage());
    case AppRoutes.register:
      return _pageRoute(settings, const RegisterPage());
    case AppRoutes.patientHome:
    case AppRoutes.legacyPatientHome:
      return _pageRoute(settings, const PatientMainPage());
    case AppRoutes.medications: {
      final patientId = args?['patientId'];
      if (patientId is! String || patientId.isEmpty) {
        return _unknownRoute(settings);
      }
      return _pageRoute(
        settings,
        BlocProvider(
          create: (_) => MedicationCubit(getIt<IMedicationRepository>()),
          child: MedicationListPage(patientId: patientId),
        ),
      );
    }
    case AppRoutes.addMedication: {
      final patientId = args?['patientId'];
      final createdBy = args?['createdBy'];
      if (patientId is! String || patientId.isEmpty) {
        return _unknownRoute(settings);
      }
      if (createdBy != null && createdBy is! String) {
        return _unknownRoute(settings);
      }
      return _pageRoute(
        settings,
        BlocProvider(
          create: (_) => MedicationCubit(getIt<IMedicationRepository>()),
          child: AddMedicationPage(
            patientId: patientId,
            createdBy: createdBy as String? ?? '',
          ),
        ),
      );
    }
    case AppRoutes.reminders: {
      final patientId = args?['patientId'];
      if (patientId is! String || patientId.isEmpty) {
        return _unknownRoute(settings);
      }
      return _pageRoute(
        settings,
        BlocProvider(
          create: (_) => ReminderCubit(
            intakeLogRepository: getIt<IIntakeLogRepository>(),
            medicationRepository: getIt<IMedicationRepository>(),
          ),
          child: TodayRemindersPage(patientId: patientId),
        ),
      );
    }
    case AppRoutes.patientPairing: {
      final patientId = args?['patientId'];
      final patientName = args?['patientName'];
      if (patientId is! String ||
          patientId.isEmpty ||
          patientName is! String) {
        return _unknownRoute(settings);
      }
      return _pageRoute(
        settings,
        BlocProvider(
          create: (_) => PairingCubit(getIt<IPairingRepository>()),
          child: PairCodePage(
            patientId: patientId,
            patientName: patientName,
          ),
        ),
      );
    }
    case AppRoutes.caregiverDashboard:
      return _pageRoute(settings, const CaregiverMainPage());
    case AppRoutes.caregiverPairing: {
      final caregiverId = args?['caregiverId'];
      final caregiverName = args?['caregiverName'];
      if (caregiverId is! String ||
          caregiverId.isEmpty ||
          caregiverName is! String) {
        return _unknownRoute(settings);
      }
      return _pageRoute(
        settings,
        BlocProvider(
          create: (_) => PairingCubit(getIt<IPairingRepository>()),
          child: EnterPairCodePage(
            caregiverId: caregiverId,
            caregiverName: caregiverName,
          ),
        ),
      );
    }
    case AppRoutes.doctorDashboard:
      return _pageRoute(settings, const DoctorMainPage());
  }

  final patientId = name == AppRoutes.patientDetail
      ? args?['patientId']
      : name != null && name.startsWith(AppRoutes.patientDetailPrefix)
          ? name.substring(AppRoutes.patientDetailPrefix.length)
          : null;
  if (patientId is String) {
    final patientName = args?['patientName'];
    final doctor = args?['doctor'];

    if (patientId.isNotEmpty &&
        patientName is String &&
        doctor is UserEntity) {
      return _pageRoute(
        settings,
        DoctorPatientDetailPage(
          patientId: patientId,
          patientName: patientName,
          doctor: doctor,
        ),
      );
    }
  }

  return _unknownRoute(settings);
}

Map<String, dynamic>? _routeArguments(RouteSettings settings) {
  final arguments = settings.arguments;
  if (arguments is Map) {
    if (arguments.keys.any((key) => key is! String)) {
      return null;
    }
    return Map<String, dynamic>.from(arguments);
  }
  return null;
}

MaterialPageRoute<dynamic> _pageRoute(
  RouteSettings settings,
  Widget child,
) {
  return MaterialPageRoute(
    settings: settings,
    builder: (_) => child,
  );
}

MaterialPageRoute<dynamic> _unknownRoute(RouteSettings settings) {
  return _pageRoute(
    settings,
    UnknownRoutePage(routeName: settings.name),
  );
}
