import 'app_language_cubit.dart';

class AppStrings {
  static AppLanguage _lang = AppLanguage.ar;

  static void setLanguage(AppLanguage lang) {
    _lang = lang;
  }

  static bool get isAr => _lang == AppLanguage.ar;

  static String pick(String ar, String en) => isAr ? ar : en;

  static String get appTitle => pick('ميديكير', 'MediCare');
  static String get loading => pick('جاري التحميل...', 'Loading...');
  static String get retry => pick('إعادة المحاولة', 'Retry');
  static String get save => pick('حفظ', 'Save');
  static String get cancel => pick('إلغاء', 'Cancel');
  static String get delete => pick('حذف', 'Delete');
  static String get add => pick('إضافة', 'Add');
  static String get confirm => pick('تأكيد', 'Confirm');
  static String get signOut => pick('تسجيل الخروج', 'Sign out');
  static String get signOutQuestion => pick(
      'هل أنت متأكد من تسجيل الخروج؟', 'Are you sure you want to sign out?');

  static String get tabHome => pick('الرئيسية', 'Home');
  static String get tabReminders => pick('تذكيرات اليوم', 'Today');
  static String get tabMedications => pick('الأدوية', 'Medications');
  static String get tabProfile => pick('الملف الطبي', 'Medical profile');
  static String get tabPairPatient => pick('ربط مريض', 'Link patient');
  static String get tabDoctorPairing =>
      pick('ربط مريض جديد', 'Link new patient');

  static String get menuTitle => pick('القائمة الرئيسية', 'Main menu');
  static String get menuServices => pick('الخدمات الذكية', 'Smart services');
  static String get menuLanguage => pick('اللغة', 'Language');
  static String get currentLanguage => pick('العربية', 'English');
  static String get switchToEnglish => pick('English', 'English');
  static String get switchToArabic => pick('العربية', 'Arabic');
  static String get menuLogout => signOut;
  static String get menuDashboard => pick('لوحة المتابعة', 'Dashboard');
  static String get menuDoctorDashboard =>
      pick('لوحة المرضى', 'Patients dashboard');
  static String get menuLabReports => pick('تقارير التحاليل', 'Lab reports');
  static String get menuLabReportsSub => pick(
      'تحليل التقارير واستخراج المؤشرات',
      'Scan reports and extract biomarkers');
  static String get menuRecommendations =>
      pick('توصيات الصحة', 'Health advice');
  static String get menuRecommendationsSub =>
      pick('غذاء وتمارين مناسبة لحالتك', 'Diet and exercise suggestions');
  static String get menuVitals => pick('المؤشرات الحيوية', 'Vital signs');
  static String get menuVitalsSub => pick('النبض والضغط والأكسجين والحرارة',
      'Heart rate, BP, SpO2 and temperature');
  static String get menuAnalytics =>
      pick('إحصائيات الالتزام', 'Adherence analytics');
  static String get menuAnalyticsSub =>
      pick('نسب الالتزام والجرعات الفائتة', 'Adherence rates and missed doses');
  static String get menuPairing =>
      pick('ربط مقدم الرعاية', 'Caregiver pairing');
  static String get menuPairingSub =>
      pick('مشاركة كود الربط مع العائلة أو الطبيب', 'Share your pairing code');

  static String get rolePatient => pick('مريض', 'Patient');
  static String get roleCaregiver => pick('مقدم رعاية', 'Caregiver');
  static String get roleDoctor => pick('طبيب', 'Doctor');
  static String get genericUser => pick('مستخدم ميديكير', 'MediCare user');

  static String get loginTitle => pick('تسجيل الدخول', 'Sign in');
  static String get loginWelcome => pick('مرحبًا بك', 'Welcome back');
  static String get loginSubtitle => pick('سجّل دخولك لمتابعة أدويتك وصحتك',
      'Sign in to manage your health routine');
  static String get registerTitle => pick('إنشاء حساب جديد', 'Create account');
  static String get registerSubtitle =>
      pick('انضم إلى ميديكير اليوم', 'Join MediCare today');
  static String get email => pick('البريد الإلكتروني', 'Email address');
  static String get password => pick('كلمة المرور', 'Password');
  static String get confirmPassword =>
      pick('تأكيد كلمة المرور', 'Confirm password');
  static String get fullName => pick('الاسم الكامل', 'Full name');
  static String get roleSelect => pick('أنا...', 'I am...');
  static String get noAccount =>
      pick('ليس لديك حساب؟', "Don't have an account?");
  static String get haveAccount =>
      pick('لديك حساب بالفعل؟', 'Already have an account?');
  static String get createAccount => pick('إنشاء حساب', 'Create account');
  static String get enterEmail =>
      pick('من فضلك أدخل البريد الإلكتروني', 'Please enter your email');
  static String get invalidEmail =>
      pick('البريد الإلكتروني غير صحيح', 'Enter a valid email');
  static String get enterPassword =>
      pick('من فضلك أدخل كلمة المرور', 'Please enter your password');
  static String get shortPassword => pick(
      'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
      'Password must be at least 6 characters');
  static String get passwordsDoNotMatch =>
      pick('كلمة المرور غير متطابقة', 'Passwords do not match');
  static String get enterName =>
      pick('من فضلك أدخل اسمك', 'Please enter your name');
  static String get shortName => pick('الاسم يجب أن يكون 3 أحرف على الأقل',
      'Name must be at least 3 characters');
  static String get acceptDisclaimerFirst => pick(
      'يرجى الموافقة على إخلاء المسؤولية الطبي أولًا',
      'Please accept the medical disclaimer first');

  static String get morningGreeting => pick('صباح الخير', 'Good morning');
  static String get eveningGreeting => pick('مساء الخير', 'Good evening');
  static String get welcomeSubtitle => pick(
      'اعتنِ بصحتك والتزم بجرعاتك اليومية',
      'Keep your treatment plan on track today');
  static String get todaySummary => pick('ملخص اليوم', "Today's summary");
  static String get taken => pick('تم التناول', 'Taken');
  static String get missed => pick('فائتة', 'Missed');
  static String get pending => pick('انتظار', 'Pending');
  static String get snoozed => pick('مؤجلة', 'Snoozed');
  static String get nextDose => pick('الجرعة القادمة', 'Next dose');
  static String dosesTaken(int taken, int total) => pick(
      'تناولت $taken من $total جرعة اليوم',
      'You took $taken of $total doses today');
  static String get connected =>
      pick('تم استعادة الاتصال', 'Connection restored');
  static String get offline =>
      pick('لا يوجد اتصال بالإنترنت', 'No internet connection');

  static String get addMedication => pick('إضافة دواء جديد', 'Add medication');
  static String get editMedication => pick('تعديل الدواء', 'Edit medication');
  static String get myMedications => pick('أدويتي', 'My medications');
  static String get medicationSearchHint =>
      pick('ابحث عن دواء بالاسم أو اللون...', 'Search by name or color...');
  static String medicationCount(int count) =>
      pick('$count دواء مسجل', '$count medications');
  static String get noMedications => pick('لا توجد أدوية', 'No medications');
  static String get noResults => pick('لا توجد نتائج', 'No results');
  static String get tryAnotherSearch =>
      pick('جرّب البحث بكلمة أخرى', 'Try another search');
  static String get addFirstMedication =>
      pick('اضغط + لإضافة دوائك الأول', 'Tap + to add your first medication');
  static String get medicationDeleted =>
      pick('تم حذف الدواء بنجاح', 'Medication deleted');
  static String deleteMedicationQuestion(String name) =>
      pick('هل تريد حذف $name؟', 'Delete $name?');
  static String get testNotification =>
      pick('اختبار الإشعار', 'Test notification');
  static String get testNotificationSent =>
      pick('تم إرسال إشعار تجريبي', 'Test notification sent');

  static String get remindersTitle =>
      pick('تذكيرات اليوم', "Today's reminders");
  static String get noRemindersToday =>
      pick('لا توجد تذكيرات اليوم', 'No reminders today');
  static String get addMedicationsToSeeReminders => pick(
      'أضف أدوية لتظهر هنا بمواعيدها',
      'Add medications to see scheduled reminders here');
  static String doseTime(String time) =>
      pick('موعد الجرعة: $time', 'Dose time: $time');
  static String get takeNow => pick('تناولت الدواء الآن', 'Taken now');
  static String get skip => pick('تخطي', 'Skip');

  static String get vitalsTitle => pick('المؤشرات الحيوية', 'Vital signs');
  static String get vitalsHomeTitle =>
      pick('المؤشرات الحيوية والساعة', 'Vitals and smartwatch');
  static String get vitalsHomeSubtitle => pick(
      'متابعة النبض والضغط والأكسجين والحرارة',
      'Track heart rate, blood pressure, SpO2 and temperature');
  static String get syncSmartwatch =>
      pick('مزامنة الساعة الذكية', 'Sync smartwatch');
  static String get bloodPressure => pick('ضغط الدم', 'Blood pressure');
  static String get heartRate => pick('نبضات القلب', 'Heart rate');
  static String get oxygenSat => pick('نسبة الأكسجين', 'Oxygen saturation');
  static String get bodyTemp => pick('درجة الحرارة', 'Body temperature');
  static String get addManualVital =>
      pick('إضافة قراءة يدوية', 'Add manual reading');

  static String get pairingSection =>
      pick('الربط والمتابعة', 'Pairing and follow-up');
  static String get linkCaregiver =>
      pick('ربط مقدم الرعاية', 'Link a caregiver');
  static String get linkCaregiverSubtitle => pick(
      'اربط حسابك مع أحد أفراد العائلة أو طبيبك',
      'Share access with family or your doctor');

  static String get labReportsTitle => pick('تقارير التحاليل', 'Lab reports');
  static String get uploadLabPhoto =>
      pick('تصوير تقرير تحليل جديد', 'Scan new lab report');
  static String get aiSummaryTitle =>
      pick('ماذا تعني نتائجك؟', 'What do your results mean?');
  static String get biomarkerTable =>
      pick('المؤشرات المستخرجة', 'Extracted biomarkers');
  static String get foodRecommended =>
      pick('أطعمة موصى بها', 'Recommended foods');
  static String get foodAvoid => pick('أطعمة يُفضل تجنبها', 'Foods to avoid');
  static String get safeExercise => pick('تمارين آمنة', 'Safe exercises');
  static String get disclaimerNotice => pick(
      'تنبيه طبي: تحليل الذكاء الاصطناعي للتوعية فقط ولا يغني عن الطبيب.',
      'Medical notice: AI analysis is for guidance only and does not replace your physician.');

  static String get caregiverDashboard =>
      pick('لوحة المتابعة', 'Care dashboard');
  static String get linkedPatients =>
      pick('المرضى المرتبطون', 'Linked patients');
  static String get patients => pick('المرضى', 'Patients');
  static String get medications => pick('الأدوية', 'Medications');
  static String get averageAdherence =>
      pick('متوسط الالتزام', 'Average adherence');
  static String get noLinkedPatients =>
      pick('لا يوجد مرضى مرتبطون', 'No linked patients');
  static String get linkPatientHint => pick(
      'افتح القائمة واختر ربط مريض لإضافة مريض',
      'Open the menu and choose Link patient');

  static String get doctorProfileTitle =>
      pick('ملف الطبيب والإعدادات', 'Doctor profile and settings');
  static String get doctorDefaultSpecialty => pick('طبيب معالج', 'Doctor');
  static String licenseNumber(String value) =>
      pick('ترخيص رقم: $value', 'License: $value');
  static String get medicalDisclaimerTerms =>
      pick('إخلاء المسؤولية الطبي والشروط', 'Medical disclaimer and terms');
  static String get medicalDisclaimerSubtitle => pick(
      'عرض التنبيه الطبي والخصوصية', 'View medical notice and privacy terms');

  // ── Medication Form & Add/Edit ──────────────────────────────────────────
  static String get formTablet => pick('قرص', 'Tablet');
  static String get formCapsule => pick('كبسولة', 'Capsule');
  static String get formSyrup => pick('شراب', 'Syrup');
  static String get formInjection => pick('حقنة', 'Injection');
  static String get formDrops => pick('قطرة', 'Drops');
  static String get formCream => pick('كريم', 'Cream');

  static String get drugBoxPhotoLabel =>
      pick('صورة علبة الدواء (اختياري)', 'Drug box photo (optional)');
  static String get drugBoxVisualBanner => pick(
      'تخصيص الهوية البصرية لكبار السن والأميين (تصوير علبة الدواء واختيار لونها)',
      'Visual ID for elderly & low-literacy patients (photo + color)');
  static String get drugBoxColorLabel =>
      pick('لون علبة / شريط الدواء', 'Drug box / strip color');
  static String get drugBoxPickPrompt =>
      pick('اضغط لتصوير علبة الدواء الحقيقية', 'Tap to photo the drug box');
  static String get drugBoxPickSheet =>
      pick('التقاط/اختيار صورة علبة الدواء', 'Capture or select drug box image');
  static String get drugBoxCamera => pick('الكاميرا المباشرة', 'Camera');
  static String get drugBoxGallery => pick('معرض الصور', 'Gallery');
  static String get drugBoxPickError =>
      pick('تعذر التقاط/اختيار الصورة', 'Could not capture / pick image');

  static String get medNameEn =>
      pick('اسم الدواء (إنجليزي)', 'Drug name (English)');
  static String get medNameAr =>
      pick('اسم الدواء (عربي)', 'Drug name (Arabic)');
  static String get enterMedName =>
      pick('من فضلك أدخل اسم الدواء', 'Please enter the drug name');
  static String get dosageLabel => pick('الجرعة', 'Dosage');
  static String get enterDosage => pick('أدخل الجرعة', 'Enter dosage');
  static String get formLabel => pick('شكل الدواء', 'Drug form');
  static String get instructionsLabel => pick('تعليمات', 'Instructions');
  static String get instructionsHint =>
      pick('مثال: تناول مع الطعام', 'e.g. Take with food');
  static String get startDateLabel => pick('تاريخ البداية', 'Start date');
  static String get doseTimesLabel => pick('مواعيد الجرعات', 'Dose times');
  static String get addDoseTime => pick('إضافة موعد', 'Add time');
  static String get atLeastOneDoseTime =>
      pick('من فضلك أضف موعد واحد على الأقل',
          'Please add at least one dose time');
  static String get saveMedButton =>
      pick('حفظ الدواء والهوية البصرية', 'Save medication');
  static String get medicationAdded =>
      pick('تم إضافة الدواء بنجاح ✓', 'Medication added successfully ✓');
  static String get medicationUpdated =>
      pick('تم تعديل الدواء بنجاح ✓', 'Medication updated successfully ✓');

  // ── Box Colors ──────────────────────────────────────────────────────────
  static String get colorRed => pick('أحمر', 'Red');
  static String get colorBlue => pick('أزرق', 'Blue');
  static String get colorGreen => pick('أخضر', 'Green');
  static String get colorYellow => pick('أصفر', 'Yellow');
  static String get colorOrange => pick('برتقالي', 'Orange');
  static String get colorPurple => pick('بنفسجي', 'Purple');
  static String get colorCyan => pick('سماوي', 'Cyan');
  static String get colorBrown => pick('بني', 'Brown');

  // ── Vitals Dashboard ────────────────────────────────────────────────────
  static String get vitalsSmartwatch =>
      pick('الساعة الذكية متصلة ⌚', 'Smartwatch connected ⌚');
  static String get vitalsSmartwatchSub => pick(
      'مزامنة فورية لنبضات القلب والضغط والأكسجين',
      'Real-time sync: heart rate, BP and SpO2');
  static String get vitalsSync => pick('مزامنة', 'Sync');
  static String get vitalsCriticalAlert => pick(
      'تنبيه طارئ: تم اكتشاف قراءات حيوية خارج المعدل الطبيعي! تم إشعار المرافق والطبيب فوراً.',
      'Emergency alert: abnormal vitals detected! Caregiver and doctor were notified.');
  static String get vitalsLatestTitle =>
      pick('آخر القراءات الحيوية الحية', 'Latest live readings');
  static String get vitalsSyncing => pick(
      'جاري المزامنة مع الحساسات والساعة الذكية... ⌚',
      'Syncing with sensors and smartwatch... ⌚');
  static String get vitalsViewHistory => pick(
      'عرض سجل القراءات والرسوم البيانية 📊',
      'View readings history and charts 📊');
  static String get vitalsHistoryTooltip =>
      pick('سجل القراءات', 'Readings history');
  static String get vitalsManualTooltip =>
      pick('إضافة يدوية', 'Add manual reading');
  static String get vitalsManualTitle =>
      pick('تسجيل قراءة حيوية جديدة', 'Record new vital reading');
  static String get vitalsSystolic =>
      pick('ضغط انقباضي (Systolic)', 'Systolic BP');
  static String get vitalsDiastolic =>
      pick('ضغط انبساطي (Diastolic)', 'Diastolic BP');
  static String get vitalsHRLabel =>
      pick('نبضات القلب (BPM)', 'Heart rate (BPM)');
  static String get vitalsSpO2Label => pick('أكسجين SpO2 (%)', 'Oxygen SpO2 (%)');
  static String get vitalsTempLabel => pick('الحرارة (°C)', 'Temperature (°C)');
  static String get vitalsSaved =>
      pick('تم حفظ القراءة الحيوية بنجاح ✓', 'Vital reading saved ✓');

  static String get statusNormal => pick('طبيعي', 'Normal');
  static String get statusHigh => pick('مرتفع', 'High');
  static String get statusLow => pick('منخفض', 'Low');
  static String get statusFast => pick('سريع', 'Fast');
  static String get statusExcellent => pick('ممتاز', 'Excellent');

  // ── Caregiver Dashboard ─────────────────────────────────────────────────
  static String get todaySummaryLabel => pick('ملخص اليوم', "Today's summary");
  static String get takenLabel => pick('تم التناول', 'Taken');
  static String get missedLabel => pick('فائتة', 'Missed');
  static String get pendingLabel => pick('انتظار', 'Pending');
  static String avgAdherenceValue(String pct) =>
      pick('متوسط الالتزام: $pct%', 'Average adherence: $pct%');
  static String patientMedCount(int count) =>
      pick('$count أدوية', '$count medications');
  static String missedDosesToday(int count) =>
      pick('فاتت $count جرعة اليوم', '$count dose(s) missed today');
  static String get vitalsMonitorButton => pick(
      'مراقبة نبضات القلب والضغط والساعة الذكية',
      'Monitor heart rate, BP & smartwatch');
  static String get emptyDashboardHint => pick(
      'اضغط على "ربط مريض" لإضافة مريض', 'Tap "Link patient" to add a patient');

  // ── Doctor Dashboard ────────────────────────────────────────────────────
  static String get doctorPatientsPanel =>
      pick('لوحة متابعة المرضى', 'Patient monitoring panel');
  static String get registeredPatients =>
      pick('المرضى المسجلين', 'Registered patients');
  static String get searchPatientHint =>
      pick('ابحث باسم المريض...', 'Search by patient name...');
  static String get myPatientsList =>
      pick('قائمة المرضى الخاضعين لمتابعتك', 'Your monitored patients');
  static String get linkNewPatient => pick('ربط مريض', 'Link patient');
  static String get createLinkCode =>
      pick('إنشاء رمز ربط مريض', 'Generate link code');
  static String get noDocPatients =>
      pick('لا يوجد مرضى خاضعين لمتابعتك حالياً', 'No patients linked yet');
  static String get noDocPatientsHint => pick(
      'يمكنك ربط المرضى بك بسهولة عن طريق مشاركة رمز الربط الخاص بك.',
      'Link patients easily by sharing your pairing code.');
  static String get noChronicDiseases =>
      pick('لا توجد أمراض مزمنة مسجلة', 'No chronic diseases on record');
  static String chronicDiseasesLabel(String list) =>
      pick('الأمراض: $list', 'Conditions: $list');
  static String get unknownPatient => pick('مريض بدون اسم', 'Unknown patient');
  static String adherencePct(String pct) =>
      pick('$pct% التزام', '$pct% adherence');

  // ── Pairing ─────────────────────────────────────────────────────────────
  static String get pairCodeTitle =>
      pick('كود الربط الخاص بك', 'Your pairing code');
  static String get pairCodeSubtitle => pick(
      'شارك هذا الكود مع مقدم الرعاية أو طبيبك حتى يتمكنوا من متابعتك',
      'Share this code with your caregiver or doctor so they can follow up with you');
  static String get pairCodeCopied =>
      pick('تم نسخ الكود', 'Code copied to clipboard');
  static String get enterPairCode =>
      pick('أدخل كود الربط', 'Enter pairing code');
  static String get enterPairCodeHint =>
      pick('الكود المكوّن من 6 أحرف', '6-character code');
  static String get pairCodeInvalid =>
      pick('من فضلك أدخل الكود كاملاً', 'Please enter the full code');
  static String get pairSuccess =>
      pick('تم الربط بنجاح ✓', 'Paired successfully ✓');
  static String get pairButton => pick('ربط الآن', 'Link now');

  // ── Adherence / Analytics ────────────────────────────────────────────────
  static String get adherenceTitle =>
      pick('إحصائيات الالتزام', 'Adherence analytics');
  static String get adherenceRate => pick('نسبة الالتزام', 'Adherence rate');
  static String get adherenceTaken => pick('جرعات مأخوذة', 'Doses taken');
  static String get adherenceMissed => pick('جرعات فائتة', 'Doses missed');
  static String get adherencePendingLabel =>
      pick('جرعات قادمة', 'Upcoming doses');
  static String get adherenceNoData =>
      pick('لا توجد بيانات كافية بعد', 'Not enough data yet');
  static String get adherenceLast7Days => pick('آخر 7 أيام', 'Last 7 days');
  static String get adherenceByMedication =>
      pick('الالتزام حسب الدواء', 'Adherence by medication');

  // ── Onboarding / Splash ──────────────────────────────────────────────────
  static String get onboardingSkip => pick('تخطي', 'Skip');
  static String get onboardingNext => pick('التالي', 'Next');
  static String get onboardingStart => pick('ابدأ الآن', 'Get started');

  // ── General ──────────────────────────────────────────────────────────────
  static String get close => pick('إغلاق', 'Close');
  static String get edit => pick('تعديل', 'Edit');
  static String get done => pick('تم', 'Done');
  static String get yes => pick('نعم', 'Yes');
  static String get no => pick('لا', 'No');
  static String get unknownError =>
      pick('حدث خطأ غير متوقع', 'An unexpected error occurred');
}
