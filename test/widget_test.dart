import 'package:flutter_test/flutter_test.dart';
import 'package:medicare_app/core/localization/app_language_cubit.dart';
import 'package:medicare_app/core/localization/app_strings.dart';

void main() {
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

      await cubit.close();
    });
  });
}