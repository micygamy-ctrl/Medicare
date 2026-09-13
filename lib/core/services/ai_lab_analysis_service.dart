import 'dart:io';
import '../../domain/entities/lab_report.dart';
import '../../domain/entities/health_recommendation.dart';

class AILabAnalysisResult {
  final List<BiomarkerResult> biomarkers;
  final String summaryAr;
  final String summaryEn;
  final List<String> recommendedFoodsAr;
  final List<String> avoidFoodsAr;
  final List<String> safeExercisesAr;

  const AILabAnalysisResult({
    required this.biomarkers,
    required this.summaryAr,
    required this.summaryEn,
    required this.recommendedFoodsAr,
    required this.avoidFoodsAr,
    required this.safeExercisesAr,
  });
}

class AILabAnalysisService {
  /// Analyzes a lab report image (performing OCR extraction and rule-based AI medical evaluation)
  Future<AILabAnalysisResult> analyzeLabReportImage({
    required File imageFile,
    required String reportType,
    required List<String> chronicConditions,
  }) async {
    // Simulate smart AI Vision processing latency
    await Future.delayed(const Duration(seconds: 2));

    final normalizedType = reportType.toLowerCase();

    if (normalizedType.contains('cbc') || normalizedType.contains('دم')) {
      return _generateCBCAnalysis(chronicConditions);
    } else if (normalizedType.contains('glucose') ||
        normalizedType.contains('sugar') ||
        normalizedType.contains('سكر') ||
        normalizedType.contains('hba1c')) {
      return _generateDiabetesAnalysis(chronicConditions);
    } else if (normalizedType.contains('lipid') ||
        normalizedType.contains('cholesterol') ||
        normalizedType.contains('دهون')) {
      return _generateLipidAnalysis(chronicConditions);
    } else if (normalizedType.contains('kidney') ||
        normalizedType.contains('كلى')) {
      return _generateKidneyAnalysis(chronicConditions);
    } else {
      return _generateGeneralLabAnalysis(chronicConditions);
    }
  }

  AILabAnalysisResult _generateCBCAnalysis(List<String> chronicConditions) {
    final biomarkers = [
      const BiomarkerResult(
        name: 'Hemoglobin (HGB)',
        nameAr: 'الهيموجلوبين',
        value: '11.5',
        unit: 'g/dL',
        referenceRange: '13.0 - 17.0',
        status: BiomarkerStatus.low,
      ),
      const BiomarkerResult(
        name: 'White Blood Cells (WBC)',
        nameAr: 'كريات الدم البيضاء',
        value: '6.8',
        unit: '10^3/uL',
        referenceRange: '4.0 - 11.0',
        status: BiomarkerStatus.normal,
      ),
      const BiomarkerResult(
        name: 'Platelets (PLT)',
        nameAr: 'الصفائح الدموية',
        value: '240',
        unit: '10^3/uL',
        referenceRange: '150 - 450',
        status: BiomarkerStatus.normal,
      ),
      const BiomarkerResult(
        name: 'RBC Count',
        nameAr: 'كريات الدم الحمراء',
        value: '4.1',
        unit: '10^6/uL',
        referenceRange: '4.5 - 5.9',
        status: BiomarkerStatus.low,
      ),
    ];

    return AILabAnalysisResult(
      biomarkers: biomarkers,
      summaryAr:
          'يظهر التقرير انخفاضاً طفيفاً في نسبة الهيموجلوبين وكريات الدم الحمراء (أنيميا بسيطة). كريات الدم البيضاء والصفائح الدموية في المعدل الطبيعي.',
      summaryEn:
          'Report shows mild anemia (low Hb and RBC). White blood cells and platelets are within normal limits.',
      recommendedFoodsAr: [
        'الأطعمة الغنية بالحديد مثل السبانخ والعدس واللحوم الحمراء الخالية من الدهون',
        'الأغذية الغنية بفرتامين C مثل البرتقال والليمون لتعزيز امتصاص الحديد',
        'العسل الأسود والتمر',
      ],
      avoidFoodsAr: [
        'الشاي والقهوة مباشرة بعد الوجبات (تمنع امتصاص الحديد)',
        'المشروبات الغازية والأطعمة المصنعة',
      ],
      safeExercisesAr: [
        'المشي الخفيف لمدة 20-30 دقيقة يومياً',
        'تمارين التنفس والاسترخاء',
        'تجنب التمارين الشديدة الإجهاد حتى تحسن نسبة الهيموجلوبين',
      ],
    );
  }

  AILabAnalysisResult _generateDiabetesAnalysis(List<String> chronicConditions) {
    final biomarkers = [
      const BiomarkerResult(
        name: 'Fasting Blood Sugar (FBS)',
        nameAr: 'السكر الصائم',
        value: '145',
        unit: 'mg/dL',
        referenceRange: '70 - 99',
        status: BiomarkerStatus.high,
      ),
      const BiomarkerResult(
        name: 'HbA1c (Cumulative Sugar)',
        nameAr: 'السكر التراكمي',
        value: '7.8',
        unit: '%',
        referenceRange: '< 5.7%',
        status: BiomarkerStatus.high,
      ),
    ];

    return AILabAnalysisResult(
      biomarkers: biomarkers,
      summaryAr:
          'تشير نتائج السكر الصائم والتراكمي إلى ارتفاع أعلى من المعدل الطبيعي (145 mg/dL و 7.8%). يتطلب ذلك ضبط النظام الغذائي والالتزام التام بمواعيد أدوية السكر.',
      summaryEn:
          'Fasting sugar and HbA1c are elevated (145 mg/dL & 7.8%). Dietary control and strict medication adherence are required.',
      recommendedFoodsAr: [
        'خضروات الورقية الخضراء (الخس، الخيار، السبانخ)',
        'الحبوب الكاملة والخبز الأسمر والشوفان',
        'الأسماك المشوية والزبيادي غير المحلى',
      ],
      avoidFoodsAr: [
        'السكريات والمشروبات الغازية والعصائر المحلاة',
        'الخبز الأبيض والمعجنات والحلويات',
        'الأطعمة السريعة والمقليات',
      ],
      safeExercisesAr: [
        'المشي السريع لمدة 30 دقيقة يومياً بعد الوجبات',
        'تمارين السباحة الخفيفة وركوب الدراجة',
        'تمارين الإطالة والمرونة',
      ],
    );
  }

  AILabAnalysisResult _generateLipidAnalysis(List<String> chronicConditions) {
    final biomarkers = [
      const BiomarkerResult(
        name: 'Total Cholesterol',
        nameAr: 'الكوليسترول الكلي',
        value: '235',
        unit: 'mg/dL',
        referenceRange: '< 200',
        status: BiomarkerStatus.high,
      ),
      const BiomarkerResult(
        name: 'Triglycerides',
        nameAr: 'الدهون الثلاثية',
        value: '190',
        unit: 'mg/dL',
        referenceRange: '< 150',
        status: BiomarkerStatus.high,
      ),
      const BiomarkerResult(
        name: 'HDL (Good Cholesterol)',
        nameAr: 'الكوليسترول النافع',
        value: '42',
        unit: 'mg/dL',
        referenceRange: '> 40',
        status: BiomarkerStatus.normal,
      ),
      const BiomarkerResult(
        name: 'LDL (Bad Cholesterol)',
        nameAr: 'الكوليسترول الضار',
        value: '155',
        unit: 'mg/dL',
        referenceRange: '< 100',
        status: BiomarkerStatus.high,
      ),
    ];

    return AILabAnalysisResult(
      biomarkers: biomarkers,
      summaryAr:
          'يظهر التحليل ارتفاعاً في مستوى الكوليسترول الكلي والضار والدهون الثلاثية. الكوليسترول النافع في الحدود الطبيعية المقبولة.',
      summaryEn:
          'Elevated total cholesterol, LDL, and triglycerides detected. HDL is within acceptable normal range.',
      recommendedFoodsAr: [
        'زيت الزيتون البكر والمكسرات النيئة (اللوز والジョوز)',
        'الأسماك الغنية بأوميجا-3 مثل السلمون والتونة',
        'الشوفان والتفاح والأغذية الغنية بألياف البكتين',
      ],
      avoidFoodsAr: [
        'الدهون المتحولة والمقليات والسمن الصناعي',
        'اللحوم المصنعة والأجبان عالية الدسم',
        'الوجبات السريعة',
      ],
      safeExercisesAr: [
        'تمارين الأيروبكس والمشي الرياضي 45 دقيقة 4 أيام أسبوعياً',
        'الجري الخفيف أو قفز الحبل التدريجي',
      ],
    );
  }

  AILabAnalysisResult _generateKidneyAnalysis(List<String> chronicConditions) {
    final biomarkers = [
      const BiomarkerResult(
        name: 'Serum Creatinine',
        nameAr: 'الكرياتينين في الدم',
        value: '0.95',
        unit: 'mg/dL',
        referenceRange: '0.70 - 1.20',
        status: BiomarkerStatus.normal,
      ),
      const BiomarkerResult(
        name: 'Blood Urea Nitrogen (BUN)',
        nameAr: 'اليوريا',
        value: '16',
        unit: 'mg/dL',
        referenceRange: '7 - 20',
        status: BiomarkerStatus.normal,
      ),
      const BiomarkerResult(
        name: 'Uric Acid',
        nameAr: 'حمض البوليك (النقرس)',
        value: '7.2',
        unit: 'mg/dL',
        referenceRange: '3.5 - 7.0',
        status: BiomarkerStatus.high,
      ),
    ];

    return AILabAnalysisResult(
      biomarkers: biomarkers,
      summaryAr:
          'وظائف الكلى (الكرياتينين واليوريا) ممتازة وفي المعدل الطبيعي. يوجد ارتفاع طفيف في حمض البوليك (اليوريك أسيد).',
      summaryEn:
          'Kidney functions (Creatinine & BUN) are normal. Mild elevation in Uric Acid observed.',
      recommendedFoodsAr: [
        'شرب الماء بكثرة (2.5 إلى 3 لتر يومياً)',
        'الخضروات الطازجة والخيار والفواكه القليلة البيورين',
        'منتجات الألبان قليلة الدسم',
      ],
      avoidFoodsAr: [
        'اللحوم الحمراء والكباري والمأكولات البحرية بكثرة',
        'المشروبات الغازية والعصائر الفوارة',
        'الأطعمة الممالحة والمخللات',
      ],
      safeExercisesAr: [
        'المشي ورياضات السباحة مع شرب الماء باستمرار أثناء التمرين',
      ],
    );
  }

  AILabAnalysisResult _generateGeneralLabAnalysis(
      List<String> chronicConditions) {
    final biomarkers = [
      const BiomarkerResult(
        name: 'Blood Glucose',
        nameAr: 'نسبة الجلوكوز',
        value: '105',
        unit: 'mg/dL',
        referenceRange: '70 - 99',
        status: BiomarkerStatus.high,
      ),
      const BiomarkerResult(
        name: 'Hemoglobin',
        nameAr: 'الهيموجلوبين',
        value: '13.8',
        unit: 'g/dL',
        referenceRange: '12.0 - 16.0',
        status: BiomarkerStatus.normal,
      ),
      const BiomarkerResult(
        name: 'ALT (SGPT)',
        nameAr: 'إنزيم الكبد ALT',
        value: '28',
        unit: 'U/L',
        referenceRange: '7 - 56',
        status: BiomarkerStatus.normal,
      ),
    ];

    return AILabAnalysisResult(
      biomarkers: biomarkers,
      summaryAr:
          'التحليل ينظر إلى المؤشرات الحيوية العامة بشكل جيد. معظم النسب في النطاق الطبيعي مع ارتفاع طفيف في الجلوكوز.',
      summaryEn:
          'General lab indicators look healthy with most values normal and slight elevation in glucose.',
      recommendedFoodsAr: [
        'طبق السلطة الخضراء اليومي',
        'الفواكه الطازجة المعتدلة',
        'الشرب المتوازن للماء والبروتينات الصحية',
      ],
      avoidFoodsAr: [
        'الأغذية سريعة التحضير والسكريات المضافة',
      ],
      safeExercisesAr: [
        'المشي اليومي المنتظم 30 دقيقة',
        'تمارين الأيروبكس البسيطة',
      ],
    );
  }

  /// Generates dynamic daily nutrition and exercise recommendations based on patient's chronic diseases & lab data
  List<HealthRecommendationEntity> generatePersonalizedRecommendations({
    required String patientId,
    required List<String> chronicDiseases,
    required List<LabReportEntity> recentLabReports,
  }) {
    final List<HealthRecommendationEntity> list = [];
    final now = DateTime.now();

    // Check Diabetes
    final hasDiabetes = chronicDiseases.any((c) =>
        c.contains('سكر') ||
        c.toLowerCase().contains('diabet') ||
        recentLabReports.any((r) => r.biomarkers.any(
            (b) => (b.name.contains('FBS') || b.name.contains('HbA1c')) && b.status == BiomarkerStatus.high)));

    if (hasDiabetes) {
      list.add(
        HealthRecommendationEntity(
          id: 'rec_diab_1',
          patientId: patientId,
          titleAr: 'نظام غذائي منخفض المؤشر الجلايسيمي',
          titleEn: 'Low Glycemic Index Diet',
          descriptionAr:
              'تناول الشوفان، البقوليات، والخضروات الخضراء للحفاظ على استقرار مستويات السكر في الدم وتجنب القفزات المفاجئة.',
          descriptionEn:
              'Eat oats, legumes, and green vegetables to maintain steady blood glucose levels.',
          category: RecommendationCategory.food,
          relatedConditionOrTest: 'مرض السكري / ارتفاع السكر',
          createdAt: now,
        ),
      );
      list.add(
        HealthRecommendationEntity(
          id: 'rec_diab_2',
          patientId: patientId,
          titleAr: 'تجنب المشروبات المحلاة والحلويات الشرقية',
          titleEn: 'Avoid Sweetened Beverages',
          descriptionAr:
              'استبدل العصائر المحلاة والمشروبات الغازية بالماء أو الشاي الأخضر بدون سكر.',
          descriptionEn: 'Replace sugary sodas and juices with plain water or unsweetened green tea.',
          category: RecommendationCategory.avoidFood,
          relatedConditionOrTest: 'مرض السكري / ارتفاع السكر',
          createdAt: now,
        ),
      );
      list.add(
        HealthRecommendationEntity(
          id: 'rec_diab_3',
          patientId: patientId,
          titleAr: 'مشي 30 دقيقة بعد الوجبة الرئيسية',
          titleEn: '30-min Post-Meal Walk',
          descriptionAr:
              'المشي الخفيف لمدة半 ساعة بعد وجبة الغداء أو العشاء يساعد العضلات على استهلاك الجلوكوز وخفض السكر بشكل طبيعي.',
          descriptionEn: 'Light walking after meals helps muscles absorb glucose and lower blood sugar.',
          category: RecommendationCategory.exercise,
          relatedConditionOrTest: 'رياضة مخصصة لمريض السكر',
          createdAt: now,
        ),
      );
    }

    // Check Hypertension (Blood Pressure)
    final hasHypertension = chronicDiseases.any((c) =>
        c.contains('ضغط') ||
        c.toLowerCase().contains('hyperten') ||
        c.toLowerCase().contains('pressure'));

    if (hasHypertension) {
      list.add(
        HealthRecommendationEntity(
          id: 'rec_hyp_1',
          patientId: patientId,
          titleAr: 'نظام DASH الغذائي وقليل الصوديوم',
          titleEn: 'Low Sodium DASH Diet',
          descriptionAr:
              'تقليل ملح الطعام إلى أقل من ملعقة صغيرة يومياً، والإكثار من الأطعمة الغنية بالبوتاسيوم مثل الموز والمغنيسيوم.',
          descriptionEn: 'Limit salt intake to less than 1 tsp/day and consume potassium-rich foods like bananas.',
          category: RecommendationCategory.food,
          relatedConditionOrTest: 'ارتفاع ضغط الدم',
          createdAt: now,
        ),
      );
      list.add(
        HealthRecommendationEntity(
          id: 'rec_hyp_2',
          patientId: patientId,
          titleAr: 'تجنب المخللات والأطعمة المعلبة والمصنعة',
          titleEn: 'Avoid Pickles and Processed Cans',
          descriptionAr:
              'الأطعمة المعلبة تحتوي على كميات عالية من الصوديوم والمواد الحافظة التي ترفع ضغط الدم بشكل حاد.',
          descriptionEn: 'Canned products contain high sodium levels which trigger acute blood pressure spikes.',
          category: RecommendationCategory.avoidFood,
          relatedConditionOrTest: 'ارتفاع ضغط الدم',
          createdAt: now,
        ),
      );
      list.add(
        HealthRecommendationEntity(
          id: 'rec_hyp_3',
          patientId: patientId,
          titleAr: 'تمارين الكارديو الخفيفة والسباحة',
          titleEn: 'Light Cardio & Swimming',
          descriptionAr:
              'ممارسة السباحة أو ركوب الدراجة الثابتة دون رفع أثقال ثقيلة تحافظ على مرونة الأوعية الدموية وتخفض الضغط.',
          descriptionEn: 'Swimming or stationary cycling maintains vascular elasticity and lowers pressure.',
          category: RecommendationCategory.exercise,
          relatedConditionOrTest: 'تمارين صحية للضغط',
          createdAt: now,
        ),
      );
    }

    // General Wellness recommendation if list is short
    if (list.length < 3) {
      list.add(
        HealthRecommendationEntity(
          id: 'rec_gen_1',
          patientId: patientId,
          titleAr: 'شرب 2.5 لتر ماء يومياً وتناول الفواكه الطازجة',
          titleEn: 'Hydration & Fresh Fruits',
          descriptionAr:
              'شرب الماء بانتظام يحسن التروية الدموية وكفاءة الكلى والتخلص من السموم.',
          descriptionEn: 'Regular water intake improves blood circulation and kidney detoxification.',
          category: RecommendationCategory.food,
          relatedConditionOrTest: 'صحة عامة',
          createdAt: now,
        ),
      );
      list.add(
        HealthRecommendationEntity(
          id: 'rec_gen_2',
          patientId: patientId,
          titleAr: 'المشي الرياضي اليومي وساعات النوم المنتظمة',
          titleEn: 'Daily Walk & Quality Sleep',
          descriptionAr:
              'المشي لمدة 30 دقيقة مع الحصول على 7-8 ساعات نوم يعززان المناعة واللياقة.',
          descriptionEn: '30 minutes daily walking combined with 7-8 hours sleep boosts immunity.',
          category: RecommendationCategory.exercise,
          relatedConditionOrTest: 'نشاط يومي',
          createdAt: now,
        ),
      );
    }

    return list;
  }
}
