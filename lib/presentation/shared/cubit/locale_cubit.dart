import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  static const String _localeKey = 'app_locale';

  LocaleCubit() : super(const Locale('ar')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString(_localeKey) ?? 'ar';
    emit(Locale(savedLanguageCode));
  }

  Future<void> changeLocale(String languageCode) async {
    if (state.languageCode == languageCode) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);
    emit(Locale(languageCode));
  }

  bool get isArabic => state.languageCode == 'ar';
}
