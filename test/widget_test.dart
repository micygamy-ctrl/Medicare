import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:medicare_app/main.dart';
import 'package:medicare_app/domain/repositories/i_auth_repository.dart';
import 'package:medicare_app/domain/repositories/i_medication_repository.dart';

class _MockAuthRepository extends Mock implements IAuthRepository {}

class _MockMedicationRepository extends Mock
    implements IMedicationRepository {}

void main() {
  final getIt = GetIt.instance;

  setUp(() async {
    await getIt.reset();

    final authRepository = _MockAuthRepository();
    final medicationRepository = _MockMedicationRepository();

    when(() => authRepository.getCurrentUser())
        .thenAnswer((_) async => null);

    getIt.registerSingleton<IAuthRepository>(authRepository);
    getIt.registerSingleton<IMedicationRepository>(medicationRepository);
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('renders the MediCare splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MediCareApp());
    await tester.pump();

    expect(find.text('Med Care'), findsOneWidget);
    expect(find.text('رعاية صحية بلا حدود'), findsOneWidget);
  });
}import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:medicare_app/main.dart';
import 'package:medicare_app/domain/repositories/i_auth_repository.dart';
import 'package:medicare_app/domain/repositories/i_medication_repository.dart';

class _MockAuthRepository extends Mock implements IAuthRepository {}

class _MockMedicationRepository extends Mock
    implements IMedicationRepository {}

void main() {
  final getIt = GetIt.instance;

  setUp(() async {
    await getIt.reset();

    final authRepository = _MockAuthRepository();
    final medicationRepository = _MockMedicationRepository();

    when(() => authRepository.getCurrentUser())
        .thenAnswer((_) async => null);

    getIt.registerSingleton<IAuthRepository>(authRepository);
    getIt.registerSingleton<IMedicationRepository>(medicationRepository);
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('renders the MediCare splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MediCareApp());
    await tester.pump();

    expect(find.text('Med Care'), findsOneWidget);
    expect(find.text('رعاية صحية بلا حدود'), findsOneWidget);
  });
}