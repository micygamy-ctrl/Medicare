import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/lab_report.dart';

class LabReportDetailPage extends StatelessWidget {
  final LabReportEntity report;

  const LabReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          report.title,
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Legal Disclaimer Badge
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.warning.withOpacity(0.5)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.gavel_rounded, color: AppColors.warning, size: 24),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'تنبيه طبي وفق معايير WHO: نتائج وتحليلات الذكاء الاصطناعي هي استئناسية للتوعية فقط ولا تغني عن استشارة الطبيب المعالج.',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // AI Plain Arabic Summary Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded,
                          color: AppColors.primary, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'ماذا تعني نتائجك؟ (ملخص الذكاء الاصطناعي)',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    report.aiSummaryAr.isNotEmpty
                        ? report.aiSummaryAr
                        : 'لم يتوفر ملخص تلقائي.',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      height: 1.6,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Biomarkers Table Card
            const Text(
              'نتائج المؤشرات الحيوية المستخرجة',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: report.biomarkers.length,
                separatorBuilder: (_, __) => Divider(
                    height: 1, color: AppColors.cardBorder.withOpacity(0.6)),
                itemBuilder: (context, index) {
                  final b = report.biomarkers[index];
                  return _BiomarkerRow(biomarker: b);
                },
              ),
            ),
            const SizedBox(height: 24),

            // Recommended Foods Card
            if (report.recommendedFoodsAr.isNotEmpty) ...[
              _RecommendationSection(
                title: '🥗 أطعمة موصى بها بناءً على نتائجك',
                color: AppColors.success,
                items: report.recommendedFoodsAr,
              ),
              const SizedBox(height: 16),
            ],

            // Avoid Foods Card
            if (report.avoidFoodsAr.isNotEmpty) ...[
              _RecommendationSection(
                title: '🚫 أطعمة يُنصح بتجنبها أو تقليلها',
                color: AppColors.error,
                items: report.avoidFoodsAr,
              ),
              const SizedBox(height: 16),
            ],

            // Safe Exercises Card
            if (report.safeExercisesAr.isNotEmpty) ...[
              _RecommendationSection(
                title: '🏃‍♂️ تمارين رياضية آمنة ومناسبة',
                color: AppColors.secondary,
                items: report.safeExercisesAr,
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

class _BiomarkerRow extends StatelessWidget {
  final BiomarkerResult biomarker;

  const _BiomarkerRow({required this.biomarker});

  Color _getStatusColor() {
    switch (biomarker.status) {
      case BiomarkerStatus.normal:
        return AppColors.success;
      case BiomarkerStatus.high:
        return AppColors.error;
      case BiomarkerStatus.low:
        return AppColors.warning;
    }
  }

  String _getStatusText() {
    switch (biomarker.status) {
      case BiomarkerStatus.normal:
        return 'طبيعي ✓';
      case BiomarkerStatus.high:
        return 'مرتفع ⬆';
      case BiomarkerStatus.low:
        return 'منخفض ⬇';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  biomarker.nameAr.isNotEmpty
                      ? biomarker.nameAr
                      : biomarker.name,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  biomarker.name,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${biomarker.value} ${biomarker.unit}',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  'المعدل: ${biomarker.referenceRange}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _getStatusText(),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationSection extends StatelessWidget {
  final String title;
  final Color color;
  final List<String> items;

  const _RecommendationSection({
    required this.title,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.fiber_manual_record, size: 8, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        height: 1.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
