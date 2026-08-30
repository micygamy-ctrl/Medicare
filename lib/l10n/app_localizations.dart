import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'Med Care'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In ar, this message translates to:
  /// **'رعاية صحية ومتابعة دقيقة للأدوية'**
  String get appTagline;

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// No description provided for @register.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب جديد'**
  String get register;

  /// No description provided for @email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get fullName;

  /// No description provided for @selectRole.
  ///
  /// In ar, this message translates to:
  /// **'اختر نوع الحساب'**
  String get selectRole;

  /// No description provided for @patient.
  ///
  /// In ar, this message translates to:
  /// **'مريض'**
  String get patient;

  /// No description provided for @patientSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'متابعة الأدوية والقياسات الصحية'**
  String get patientSubtitle;

  /// No description provided for @caregiver.
  ///
  /// In ar, this message translates to:
  /// **'مقدم رعاية'**
  String get caregiver;

  /// No description provided for @caregiverSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'متابعة التزام مريض قريب لك'**
  String get caregiverSubtitle;

  /// No description provided for @doctor.
  ///
  /// In ar, this message translates to:
  /// **'طبيب معالج'**
  String get doctor;

  /// No description provided for @doctorSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'متابعة المرضى وتحديث الروشتات'**
  String get doctorSubtitle;

  /// No description provided for @specialization.
  ///
  /// In ar, this message translates to:
  /// **'التخصص الطبي'**
  String get specialization;

  /// No description provided for @licenseNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الترخيص الطبي'**
  String get licenseNumber;

  /// No description provided for @enterSpecialization.
  ///
  /// In ar, this message translates to:
  /// **'أدخل تخصصك الطبي'**
  String get enterSpecialization;

  /// No description provided for @enterLicenseNumber.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم الترخيص النقابي/الطبي'**
  String get enterLicenseNumber;

  /// No description provided for @disclaimerTitle.
  ///
  /// In ar, this message translates to:
  /// **'إخلاء مسؤولية طبي وشروط الاستخدام'**
  String get disclaimerTitle;

  /// No description provided for @disclaimerAccept.
  ///
  /// In ar, this message translates to:
  /// **'أوافق وأفهم الشروط الطبية'**
  String get disclaimerAccept;

  /// No description provided for @doctorDashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة متابعة الطبيب'**
  String get doctorDashboard;

  /// No description provided for @myPatients.
  ///
  /// In ar, this message translates to:
  /// **'مرضاي المسجلين'**
  String get myPatients;

  /// No description provided for @addPatient.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مريض جديد'**
  String get addPatient;

  /// No description provided for @adherenceRate.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الالتزام بالأدوية'**
  String get adherenceRate;

  /// No description provided for @missedDosesAlert.
  ///
  /// In ar, this message translates to:
  /// **'جرعات فائتة تحتاج لمتابعة'**
  String get missedDosesAlert;

  /// No description provided for @viewHealthProfile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الطبي الشامل'**
  String get viewHealthProfile;

  /// No description provided for @prescriptions.
  ///
  /// In ar, this message translates to:
  /// **'الروشتات والأدوية'**
  String get prescriptions;

  /// No description provided for @addPrescription.
  ///
  /// In ar, this message translates to:
  /// **'إضافة روشتة / دواء جديد'**
  String get addPrescription;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
