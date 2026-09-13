import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { ar, en }

class AppLanguageState {
  final AppLanguage language;
  final Locale locale;

  const AppLanguageState({
    required this.language,
    required this.locale,
  });

  bool get isArabic => language == AppLanguage.ar;
  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;
}

class AppLanguageCubit extends Cubit<AppLanguageState> {
  static const String _prefKey = 'app_selected_language';

  AppLanguageCubit()
      : super(const AppLanguageState(
          language: AppLanguage.ar,
          locale: Locale('ar'),
        )) {
    loadSavedLanguage();
  }

  Future<void> loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey) ?? 'ar';
      final lang = code == 'en' ? AppLanguage.en : AppLanguage.ar;
      emit(AppLanguageState(
        language: lang,
        locale: Locale(code),
      ));
    } catch (_) {}
  }

  Future<void> changeLanguage(AppLanguage language) async {
    final code = language == AppLanguage.en ? 'en' : 'ar';
    emit(AppLanguageState(
      language: language,
      locale: Locale(code),
    ));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, code);
    } catch (_) {}
  }

  Future<void> toggleLanguage() async {
    final next =
        state.language == AppLanguage.ar ? AppLanguage.en : AppLanguage.ar;
    await changeLanguage(next);
  }
}
