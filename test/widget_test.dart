import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medicare_app/core/localization/app_language_cubit.dart';
import 'package:medicare_app/core/localization/app_strings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Localization & AppStrings Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('AppStrings defaults to Arabic strings correctly', () {
      AppStrings.setLanguage(AppLanguage.ar);
      expect(AppStrings.isAr, true);
      expect(AppStrings.appTitle, 'ميديكير');
      expect(AppStrings.tabHome, 'الرئيسية');
    });

    test('AppStrings switches to English strings correctly', () {
      AppStrings.setLanguage(AppLanguage.en);
      expect(AppStrings.isAr, false);
      expect(AppStrings.appTitle, 'MediCare');
      expect(AppStrings.tabHome, 'Home');
    });

    test('AppLanguageCubit toggles language state', () async {
      SharedPreferences.setMockInitialValues({'app_language': 'ar'});
      final cubit = AppLanguageCubit();

      expect(cubit.state.language, AppLanguage.ar);

      await cubit.toggleLanguage();

      expect(cubit.state.language, AppLanguage.en);
      expect(AppStrings.appTitle, 'MediCare');

      await cubit.close();
    });
  });
}
