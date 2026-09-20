import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:medicare_app/core/constants/app_routes.dart';
import 'package:medicare_app/domain/entities/intake_log.dart';
import 'package:medicare_app/domain/entities/medication.dart';
import 'package:medicare_app/domain/repositories/i_auth_repository.dart';
import 'package:medicare_app/domain/repositories/i_intake_log_repository.dart';
import 'package:medicare_app/domain/repositories/i_medication_repository.dart';
import 'package:medicare_app/domain/repositories/i_pairing_repository.dart';
import 'package:medicare_app/main.dart';
import 'package:medicare_app/presentation/auth/pages/login_page.dart';
import 'package:medicare_app/presentation/auth/pages/onboarding_page.dart';
import 'package:medicare_app/presentation/auth/pages/register_page.dart';
import 'package:medicare_app/presentation/auth/pages/splash_page.dart';
import 'package:medicare_app/presentation/caregiver/caregiver_main_page.dart';
import 'package:medicare_app/presentation/caregiver/pairing/pages/enter_pair_code_page.dart';
import 'package:medicare_app/presentation/doctor/doctor_main_page.dart';
import 'package:medicare_app/presentation/patient/home/patient_main_page.dart';
import 'package:medicare_app/presentation/patient/medications/pages/add_medication_page.dart';
import 'package:medicare_app/presentation/patient/medications/pages/medication_list_page.dart';
import 'package:medicare_app/presentation/patient/pairing/pages/pair_code_page.dart';
import 'package:medicare_app/presentation/patient/reminders/pages/today_reminders_page.dart';
import 'package:medicare_app/presentation/shared/pages/unknown_route_page.dart';

class _MockAuthRepository extends Mock implements IAuthRepository {}

class _MockIntakeLogRepository extends Mock implements IIntakeLogRepository {}

class _MockMedicationRepository extends Mock
    implements IMedicationRepository {}

class _MockPairingRepository extends Mock implements IPairingRepository {}

void main() {
  final getIt = GetIt.instance;

  setUp(() async {
    await getIt.reset();

    final authRepository = _MockAuthRepository();
    final intakeLogRepository = _MockIntakeLogRepository();
    final medicationRepository = _MockMedicationRepository();
    final pairingRepository = _MockPairingRepository();

    when(() => authRepository.getCurrentUser())
        .thenAnswer((_) async => null);
    when(() => medicationRepository.getPatientMedications(any()))
        .thenAnswer((_) => Stream.value(<MedicationEntity>[]));
    when(() => intakeLogRepository.getTodayLogs(any()))
        .thenAnswer((_) => Stream.value(<IntakeLogEntity>[]));
    when(() => pairingRepository.getPatientPair(any()))
        .thenAnswer((_) async => null);

    getIt.registerSingleton<IAuthRepository>(authRepository);
    getIt.registerSingleton<IIntakeLogRepository>(intakeLogRepository);
    getIt.registerSingleton<IMedicationRepository>(medicationRepository);
    getIt.registerSingleton<IPairingRepository>(pairingRepository);
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('opens the splash route', (WidgetTester tester) async {
    await _pumpApp(tester);

    expect(find.byType(SplashPage), findsOneWidget);
  });

  testWidgets('opens the authentication and onboarding routes',
      (WidgetTester tester) async {
    await _pumpRoute(tester, AppRoutes.login);
    expect(find.byType(LoginPage), findsOneWidget);

    await _pumpRoute(tester, AppRoutes.register);
    expect(find.byType(RegisterPage), findsOneWidget);

    await _pumpRoute(tester, AppRoutes.roleSelection);
    expect(find.byType(OnboardingPage), findsOneWidget);
  });

  testWidgets('opens the patient home route and legacy alias',
      (WidgetTester tester) async {
    await _pumpRoute(tester, AppRoutes.patientHome);
    expect(find.byType(PatientMainPage), findsOneWidget);

    await _pumpRoute(tester, AppRoutes.legacyPatientHome);
    expect(find.byType(PatientMainPage), findsOneWidget);
  });

  testWidgets('opens caregiver and doctor dashboard routes',
      (WidgetTester tester) async {
    await _pumpRoute(tester, AppRoutes.caregiverDashboard);
    expect(find.byType(CaregiverMainPage), findsOneWidget);

    await _pumpRoute(tester, AppRoutes.doctorDashboard);
    expect(find.byType(DoctorMainPage), findsOneWidget);
  });

  testWidgets('opens medication and reminder routes with valid arguments',
      (WidgetTester tester) async {
    await _pumpRoute(
      tester,
      AppRoutes.medications,
      arguments: {'patientId': 'patient-1'},
    );
    expect(find.byType(MedicationListPage), findsOneWidget);

    await _pumpRoute(
      tester,
      AppRoutes.addMedication,
      arguments: {
        'patientId': 'patient-1',
        'createdBy': 'patient-1',
      },
    );
    expect(find.byType(AddMedicationPage), findsOneWidget);

    await _pumpRoute(
      tester,
      AppRoutes.reminders,
      arguments: {'patientId': 'patient-1'},
    );
    expect(find.byType(TodayRemindersPage), findsOneWidget);
  });

  testWidgets('rejects missing or invalid medication and reminder arguments',
      (WidgetTester tester) async {
    final invalidArguments = <Object?>[
      null,
      <String, dynamic>{},
      <String, dynamic>{'patientId': ''},
      <String, dynamic>{'patientId': 42},
      <Object, Object>{1: 'invalid-key'},
    ];

    for (final arguments in invalidArguments) {
      await _pumpRoute(
        tester,
        AppRoutes.medications,
        arguments: arguments,
      );
      expect(find.byType(UnknownRoutePage), findsOneWidget);

      await _pumpRoute(
        tester,
        AppRoutes.addMedication,
        arguments: arguments,
      );
      expect(find.byType(UnknownRoutePage), findsOneWidget);

      await _pumpRoute(
        tester,
        AppRoutes.reminders,
        arguments: arguments,
      );
      expect(find.byType(UnknownRoutePage), findsOneWidget);
    }
  });

  testWidgets('opens patient pairing and caregiver pairing with valid arguments',
      (WidgetTester tester) async {
    await _pumpRoute(
      tester,
      AppRoutes.patientPairing,
      arguments: {
        'patientId': 'patient-1',
        'patientName': 'Patient One',
      },
    );
    expect(find.byType(PairCodePage), findsOneWidget);

    await _pumpRoute(
      tester,
      AppRoutes.caregiverPairing,
      arguments: {
        'caregiverId': 'caregiver-1',
        'caregiverName': 'Caregiver One',
      },
    );
    expect(find.byType(EnterPairCodePage), findsOneWidget);
  });

  testWidgets('rejects invalid pairing arguments', (WidgetTester tester) async {
    final invalidArguments = <Object?>[
      null,
      <String, dynamic>{'patientId': 'patient-1'},
      <String, dynamic>{'patientId': '', 'patientName': 'Patient One'},
      <String, dynamic>{'caregiverId': 42, 'caregiverName': 'Caregiver One'},
      <String, dynamic>{'caregiverId': 'caregiver-1'},
    ];

    for (final arguments in invalidArguments) {
      await _pumpRoute(
        tester,
        AppRoutes.patientPairing,
        arguments: arguments,
      );
      expect(find.byType(UnknownRoutePage), findsOneWidget);

      await _pumpRoute(
        tester,
        AppRoutes.caregiverPairing,
        arguments: arguments,
      );
      expect(find.byType(UnknownRoutePage), findsOneWidget);
    }
  });

  testWidgets('rejects incomplete patient detail arguments',
      (WidgetTester tester) async {
    await _pumpRoute(
      tester,
      AppRoutes.patientDetail,
      arguments: {
        'patientId': 'patient-1',
        'patientName': 'Patient One',
      },
    );
    expect(find.byType(UnknownRoutePage), findsOneWidget);

    await _pumpRoute(
      tester,
      '${AppRoutes.patientDetailPrefix}patient-2',
      arguments: {'patientName': 'Patient Two'},
    );
    expect(find.byType(UnknownRoutePage), findsOneWidget);
  });

  testWidgets('rejects an invalid optional add-medication argument',
      (WidgetTester tester) async {
    await _pumpRoute(
      tester,
      AppRoutes.addMedication,
      arguments: {
        'patientId': 'patient-1',
        'createdBy': 42,
      },
    );

    expect(find.byType(UnknownRoutePage), findsOneWidget);
  });

  testWidgets('shows the unknown route page for an unregistered route',
      (WidgetTester tester) async {
    const unknownRoute = '/not-registered';

    await _pumpRoute(tester, unknownRoute);

    expect(find.byType(UnknownRoutePage), findsOneWidget);
    expect(find.text(unknownRoute), findsOneWidget);
    expect(find.text('الصفحة غير موجودة'), findsOneWidget);
  });
}

Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const MediCareApp());
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _pumpRoute(
  WidgetTester tester,
  String route, {
  Object? arguments,
}) async {
  await _pumpApp(tester);
  final navigator = tester.state<NavigatorState>(find.byType(Navigator));
  navigator.pushNamedAndRemoveUntil(
    route,
    (_) => false,
    arguments: arguments,
  );
  await tester.pumpAndSettle();
}