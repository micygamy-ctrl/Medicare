import 'package:flutter_test/flutter_test.dart';
<<<<<<< HEAD
=======
import 'package:shared_preferences/shared_preferences.dart';
>>>>>>> 7ff46f90ac9e218605f8402799e008424b7c7de8
import 'package:medicare_app/core/localization/app_language_cubit.dart';
import 'package:medicare_app/core/localization/app_strings.dart';

void main() {
<<<<<<< HEAD
  group('Localization & AppStrings Tests', () {
    test('AppStrings defaults to Arabic strings correctly', () {
      AppStrings.setLanguage(AppLanguage.ar);
      expect(AppStrings.isAr, true);
      expect(AppStrings.appTitle, 'ميديكير');
      expect(AppStrings.todaySummary, 'ملخص اليوم');
    });

    test('AppStrings switches to English strings correctly', () {
      AppStrings.setLanguage(AppLanguage.en);
      expect(AppStrings.isAr, false);
      expect(AppStrings.appTitle, 'MediCare');
      expect(AppStrings.todaySummary, "Today's summary");
    });

    test('AppLanguageCubit toggles language state', () async {
      final cubit = AppLanguageCubit();
      expect(cubit.state.language, AppLanguage.ar);

      await cubit.toggleLanguage();
      expect(cubit.state.language, AppLanguage.en);

      await cubit.toggleLanguage();
      expect(cubit.state.language, AppLanguage.ar);
=======
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
>>>>>>> 7ff46f90ac9e218605f8402799e008424b7c7de8

      await cubit.close();
    });
  });
}