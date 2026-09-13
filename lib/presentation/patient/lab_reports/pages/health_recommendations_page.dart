import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/health_recommendation.dart';
import '../../../shared/widgets/error_view.dart';
import '../cubit/lab_report_cubit.dart';

class HealthRecommendationsPage extends StatefulWidget {
  final String patientId;
  final List<String> chronicConditions;

  const HealthRecommendationsPage({
    super.key,
    required this.patientId,
    required this.chronicConditions,
  });

  @override
  State<HealthRecommendationsPage> createState() =>
      _HealthRecommendationsPageState();
}

class _HealthRecommendationsPageState
    extends State<HealthRecommendationsPage> {
  int _selectedFilterIndex = 0;

  final List<String> _filterTitles = [
    'الكل',
    '🥗 الأكل الموصى به',
    '🚫 أطعمة تجنبها',
    '🏃‍♂️ التمارين الرياضية',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LabReportCubit>().loadPatientReports(
            patientId: widget.patientId,
            chronicDiseases: widget.chronicConditions,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'توصيات الأكل والرياضة اليومية',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<LabReportCubit, LabReportState>(
        builder: (context, state) {
          if (state is LabReportLoading) {
            return const LoadingView();
          }

          if (state is LabReportError) {
            return ErrorView(
              message: state.message,
              icon: Icons.restaurant_menu_outlined,
              onRetry: () => context.read<LabReportCubit>().loadPatientReports(
                    patientId: widget.patientId,
                    chronicDiseases: widget.chronicConditions,
                  ),
            );
          }

          if (state is LabReportLoaded) {
            final allRecs = state.recommendations;

            // Apply filter
            final filteredRecs = allRecs.where((r) {
              if (_selectedFilterIndex == 1) {
                return r.category == RecommendationCategory.food;
              } else if (_selectedFilterIndex == 2) {
                return r.category == RecommendationCategory.avoidFood;
              } else if (_selectedFilterIndex == 3) {
                return r.category == RecommendationCategory.exercise;
              }
              return true;
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Disclaimer Banner
                Container(
                  width: double.infinity,
                  color: AppColors.primaryLight,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded,
                          color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'توصيات الذكاء الاصطناعي مخصصة حسب أمراضك المزمنة ونتائج آخر تحاليلك الطبية.',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Category Horizontal Filter
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filterTitles.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final isSelected = _selectedFilterIndex == index;
                        return ChoiceChip(
                          label: Text(
                            _filterTitles[index],
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surface,
                          onSelected: (_) =>
                              setState(() => _selectedFilterIndex = index),
                        );
                      },
                    ),
                  ),
                ),

                // Recommendations List
                Expanded(
                  child: filteredRecs.isEmpty
                      ? const Center(
                          child: Text(
                            'لا توجد توصيات في هذا الفلتر',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredRecs.length,
                          itemBuilder: (context, index) {
                            return _RecommendationCard(
                                recommendation: filteredRecs[index]);
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final HealthRecommendationEntity recommendation;

  const _RecommendationCard({required this.recommendation});

  Color _getCategoryColor() {
    switch (recommendation.category) {
      case RecommendationCategory.food:
        return AppColors.success;
      case RecommendationCategory.avoidFood:
        return AppColors.error;
      case RecommendationCategory.exercise:
        return AppColors.secondary;
      case RecommendationCategory.lifestyle:
        return AppColors.primary;
    }
  }

  IconData _getCategoryIcon() {
    switch (recommendation.category) {
      case RecommendationCategory.food:
        return Icons.restaurant_rounded;
      case RecommendationCategory.avoidFood:
        return Icons.block_rounded;
      case RecommendationCategory.exercise:
        return Icons.directions_run_rounded;
      case RecommendationCategory.lifestyle:
        return Icons.spa_rounded;
    }
  }

  String _getCategoryBadgeText() {
    switch (recommendation.category) {
      case RecommendationCategory.food:
        return 'طعام موصى به';
      case RecommendationCategory.avoidFood:
        return 'طعام ينبغي تجنبه';
      case RecommendationCategory.exercise:
        return 'تمرين رياضي آمن';
      case RecommendationCategory.lifestyle:
        return 'نمط حياة صحي';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_getCategoryIcon(), color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation.titleAr,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'مبني على: ${recommendation.relatedConditionOrTest}',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getCategoryBadgeText(),
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
            const SizedBox(height: 12),
            Text(
              recommendation.descriptionAr,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
