import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/vital_sign.dart';
import '../../../shared/widgets/error_view.dart';
import '../cubit/vitals_cubit.dart';

class VitalsHistoryPage extends StatelessWidget {
  final String patientId;

  const VitalsHistoryPage({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'سجل قراءات المؤشرات الحيوية',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surface,
      ),
      body: BlocBuilder<VitalsCubit, VitalsState>(
        builder: (context, state) {
          if (state is VitalsLoading) {
            return const LoadingView();
          }

          if (state is VitalsError) {
            return ErrorView(
              message: state.message,
              icon: Icons.monitor_heart_outlined,
              onRetry: () =>
                  context.read<VitalsCubit>().loadPatientVitals(patientId),
            );
          }

          if (state is VitalsLoaded) {
            if (state.vitals.isEmpty) {
              return const Center(
                child: Text(
                  'لا توجد قراءات حيوية سابقة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.vitals.length,
              itemBuilder: (context, index) {
                final item = state.vitals[index];
                return _VitalHistoryCard(
                  item: item,
                  onDelete: () =>
                      context.read<VitalsCubit>().deleteReading(item.id),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _VitalHistoryCard extends StatelessWidget {
  final VitalSignEntity item;
  final VoidCallback onDelete;

  const _VitalHistoryCard({
    required this.item,
    required this.onDelete,
  });

  Color _getStatusColor() {
    switch (item.status) {
      case VitalStatus.normal:
        return AppColors.success;
      case VitalStatus.warning:
        return AppColors.warning;
      case VitalStatus.critical:
        return AppColors.error;
    }
  }

  String _getStatusText() {
    switch (item.status) {
      case VitalStatus.normal:
        return 'طبيعي';
      case VitalStatus.warning:
        return 'تحذير';
      case VitalStatus.critical:
        return 'حرج ⚠️';
    }
  }

  String _getSourceText() {
    switch (item.source) {
      case VitalSource.smartwatch:
        return 'ساعة ذكية ⌚';
      case VitalSource.bluetoothSensor:
        return 'حساس بلوتوث 📡';
      case VitalSource.healthKit:
        return 'تطبيق الصحة';
      case VitalSource.manual:
        return 'إدخال يدوي ✍️';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final dateStr =
        '${item.timestamp.day}/${item.timestamp.month} — ${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.4), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusText(),
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getSourceText(),
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: AppColors.textHint,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          size: 18, color: AppColors.error),
                      onPressed: onDelete,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.only(right: 8),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSubMetric(
                    'ضغط الدم', '${item.systolicBP}/${item.diastolicBP}', 'mmHg'),
                _buildSubMetric('النبض', '${item.heartRate}', 'BPM'),
                _buildSubMetric('الأكسجين', '${item.spO2}%', 'SpO2'),
                _buildSubMetric('الحرارة', '${item.temperature}°', 'C'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubMetric(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
