import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../../domain/repositories/i_pairing_repository.dart';
import '../../../domain/repositories/i_medication_repository.dart';
import '../../../domain/repositories/i_intake_log_repository.dart';
import '../../../domain/repositories/i_vitals_repository.dart';
import '../../../core/di/injection.dart';
import '../../patient/vitals/cubit/vitals_cubit.dart';
import '../../patient/vitals/pages/vitals_dashboard_page.dart';
import 'cubit/dashboard_cubit.dart';

class CaregiverDashboardPage extends StatelessWidget {
  const CaregiverDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final user =
            authState is AuthAuthenticated ? authState.user : null;

        return BlocProvider(
          create: (_) => DashboardCubit(
            pairingRepository: getIt<IPairingRepository>(),
            medicationRepository: getIt<IMedicationRepository>(),
            intakeLogRepository: getIt<IIntakeLogRepository>(),
          )..loadDashboard(user?.uid ?? ''),
          child: _DashboardView(
            caregiverId: user?.uid ?? '',
            caregiverName: user?.displayName ?? '',
          ),
        );
      },
    );
  }
}

class _DashboardView extends StatelessWidget {
  final String caregiverId;
  final String caregiverName;

  const _DashboardView({
    required this.caregiverId,
    required this.caregiverName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('لوحة المتابعة'),
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(
              child:
                  CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 48),
                  const SizedBox(height: 16),
                  Text(state.message, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<DashboardCubit>()
                        .loadDashboard(caregiverId),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is DashboardLoaded) {
            if (state.patients.isEmpty) {
              return _EmptyDashboard(caregiverId: caregiverId);
            }

            return RefreshIndicator(
              onRefresh: () async => context
                  .read<DashboardCubit>()
                  .loadDashboard(caregiverId),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Header
                    _SummaryCard(patients: state.patients),
                    const SizedBox(height: 24),

                    // Patients List
                    Text(
                      'المرضى المرتبطون (${state.patients.length})',
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: 12),
                    ...state.patients.map(
                      (summary) => _PatientCard(summary: summary),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

// Summary Card
class _SummaryCard extends StatelessWidget {
  final List<PatientSummary> patients;

  const _SummaryCard({required this.patients});

  @override
  Widget build(BuildContext context) {
    final totalMedications =
        patients.fold(0, (sum, p) => sum + p.medications.length);
    final totalTaken =
        patients.fold(0, (sum, p) => sum + p.takenToday);
    final totalMissed =
        patients.fold(0, (sum, p) => sum + p.missedToday);
    final avgAdherence = patients.isEmpty
        ? 0.0
        : patients.fold(
                0.0, (sum, p) => sum + p.adherencePercentage) /
            patients.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.monitor_heart_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'ملخص اليوم',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'المرضى',
                  value: patients.length.toString(),
                  icon: Icons.people_rounded,
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  label: 'الأدوية',
                  value: totalMedications.toString(),
                  icon: Icons.medication_rounded,
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  label: 'تم التناول',
                  value: totalTaken.toString(),
                  icon: Icons.check_circle_rounded,
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  label: 'فائتة',
                  value: totalMissed.toString(),
                  icon: Icons.cancel_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.trending_up_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'متوسط الالتزام: ${avgAdherence.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.85), size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Cairo',
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// Patient Card
class _PatientCard extends StatelessWidget {
  final PatientSummary summary;

  const _PatientCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final adherence = summary.adherencePercentage;
    final adherenceColor = adherence >= 80
        ? AppColors.success
        : adherence >= 50
            ? AppColors.warning
            : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.pair.patientName,
                        style: AppTextStyles.label,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${summary.medications.length} أدوية',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),

                // Adherence Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: adherenceColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: adherenceColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    '${adherence.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: adherenceColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: 'تم التناول',
                    value: summary.takenToday.toString(),
                    color: AppColors.success,
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MiniStat(
                    label: 'فائتة',
                    value: summary.missedToday.toString(),
                    color: AppColors.error,
                    icon: Icons.cancel_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MiniStat(
                    label: 'انتظار',
                    value: summary.pendingToday.toString(),
                    color: AppColors.primary,
                    icon: Icons.access_time_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Smartwatch & Vitals Monitoring Button
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => VitalsCubit(getIt<IVitalsRepository>()),
                      child: VitalsDashboardPage(patientId: summary.pair.patientId),
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.watch_rounded, color: AppColors.primary, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'مراقبة نبضات القلب والضغط والساعة الذكية',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
                  ],
                ),
              ),
            ),

            // Alert
            if (summary.missedToday > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.error, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'فاتت ${summary.missedToday} جرعة اليوم',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

// Empty State
class _EmptyDashboard extends StatelessWidget {
  final String caregiverId;

  const _EmptyDashboard({required this.caregiverId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 52,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text('لا يوجد مرضى مرتبطون',
                style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              'اضغط على "ربط مريض" لإضافة مريض',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}