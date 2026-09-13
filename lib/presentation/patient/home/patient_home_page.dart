import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/intake_log.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/i_vitals_repository.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../shared/widgets/app_drawer.dart';
import '../medications/cubit/medication_cubit.dart';
import '../medications/pages/medication_list_page.dart';
import '../pairing/cubit/pairing_cubit.dart';
import '../pairing/pages/pair_code_page.dart';
import '../profile/pages/patient_profile_page.dart';
import '../reminders/cubit/reminder_cubit.dart';
import '../reminders/pages/today_reminders_page.dart';
import '../vitals/cubit/vitals_cubit.dart';
import '../vitals/pages/vitals_dashboard_page.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<ReminderCubit>().loadTodayReminders(authState.user.uid);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    return hour < 12 ? AppStrings.morningGreeting : AppStrings.eveningGreeting;
  }

  void _openMainItem(BuildContext context, int index, UserEntity? user) {
    if (user == null || index == 0) return;

    final page = switch (index) {
      1 => BlocProvider.value(
          value: context.read<ReminderCubit>(),
          child: TodayRemindersPage(patientId: user.uid),
        ),
      2 => BlocProvider.value(
          value: context.read<MedicationCubit>(),
          child: MedicationListPage(patientId: user.uid),
        ),
      3 => PatientProfilePage(user: user),
      _ => const SizedBox.shrink(),
    };

    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;

        return Scaffold(
          backgroundColor: AppColors.background,
          drawer: AppDrawer(
            user: user,
            selectedIndex: 0,
            onSelectMainItem: (index) => _openMainItem(context, index, user),
          ),
          appBar: AppBar(
            title: Text(AppStrings.appTitle),
            leading: Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                tooltip: AppStrings.signOut,
                onPressed: () => _confirmLogout(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _WelcomeCard(
                  name: user?.displayName ?? '',
                  greeting: _getGreeting(),
                ),
                const SizedBox(height: 20),
                BlocBuilder<ReminderCubit, ReminderState>(
                  builder: (context, reminderState) {
                    if (reminderState is ReminderLoaded) {
                      return _TodaySummaryCard(logs: reminderState.logs);
                    }
                    return const SizedBox();
                  },
                ),
                const SizedBox(height: 20),
                BlocBuilder<ReminderCubit, ReminderState>(
                  builder: (context, reminderState) {
                    if (reminderState is ReminderLoaded) {
                      final pending = reminderState.logs
                          .where((l) => l.status == IntakeStatus.pending)
                          .toList();
                      if (pending.isNotEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppStrings.nextDose, style: AppTextStyles.h3),
                            const SizedBox(height: 12),
                            _NextReminderCard(log: pending.first),
                            const SizedBox(height: 20),
                          ],
                        );
                      }
                    }
                    return const SizedBox();
                  },
                ),
                Text(AppStrings.vitalsHomeTitle, style: AppTextStyles.h3),
                const SizedBox(height: 12),
                _ActionCard(
                  icon: Icons.watch_rounded,
                  title: AppStrings.syncSmartwatch,
                  subtitle: AppStrings.vitalsHomeSubtitle,
                  color: AppColors.primary,
                  onTap: () {
                    if (user != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) =>
                                VitalsCubit(getIt<IVitalsRepository>()),
                            child: VitalsDashboardPage(patientId: user.uid),
                          ),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                Text(AppStrings.pairingSection, style: AppTextStyles.h3),
                const SizedBox(height: 12),
                _ActionCard(
                  icon: Icons.link_rounded,
                  title: AppStrings.linkCaregiver,
                  subtitle: AppStrings.linkCaregiverSubtitle,
                  color: AppColors.secondary,
                  onTap: () {
                    if (user != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<PairingCubit>(),
                            child: PairCodePage(
                              patientId: user.uid,
                              patientName: user.displayName,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.signOut,
            style: const TextStyle(fontFamily: 'Cairo')),
        content: Text(
          AppStrings.signOutQuestion,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel,
                style: const TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(AppStrings.signOut,
                style: const TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final String name;
  final String greeting;

  const _WelcomeCard({required this.name, required this.greeting});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite_rounded,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          AppStrings.welcomeSubtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.92),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medical_services_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodaySummaryCard extends StatelessWidget {
  final List<IntakeLogEntity> logs;

  const _TodaySummaryCard({required this.logs});

  @override
  Widget build(BuildContext context) {
    final taken = logs.where((l) => l.status == IntakeStatus.taken).length;
    final missed = logs.where((l) => l.status == IntakeStatus.missed).length;
    final pending = logs.where((l) => l.status == IntakeStatus.pending).length;
    final total = logs.length;

    if (total == 0) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.todaySummary, style: AppTextStyles.h3),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MiniStatItem(
                      label: AppStrings.taken,
                      value: taken,
                      color: AppColors.success,
                      icon: Icons.check_circle_rounded,
                    ),
                  ),
                  Expanded(
                    child: _MiniStatItem(
                      label: AppStrings.missed,
                      value: missed,
                      color: AppColors.error,
                      icon: Icons.cancel_rounded,
                    ),
                  ),
                  Expanded(
                    child: _MiniStatItem(
                      label: AppStrings.pending,
                      value: pending,
                      color: AppColors.primary,
                      icon: Icons.access_time_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: taken / total,
                  backgroundColor: AppColors.divider,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.success),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.dosesTaken(taken, total),
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniStatItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _MiniStatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _NextReminderCard extends StatelessWidget {
  final IntakeLogEntity log;

  const _NextReminderCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final time =
        '${log.scheduledTime.hour.toString().padLeft(2, '0')}:${log.scheduledTime.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.medication_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.medicationName, style: AppTextStyles.label),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              AppStrings.pending,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.label),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
