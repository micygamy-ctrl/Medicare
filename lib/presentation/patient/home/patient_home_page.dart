import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../pairing/cubit/pairing_cubit.dart';
import '../pairing/pages/pair_code_page.dart';
import '../reminders/cubit/reminder_cubit.dart';
import '../../../../domain/entities/intake_log.dart';

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
      context
          .read<ReminderCubit>()
          .loadTodayReminders(authState.user.uid);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير';
    if (hour < 17) return 'مساء الخير';
    return 'مساء النور';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Med Care'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded),
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

                // Welcome Card
                _WelcomeCard(
                  name: user?.displayName ?? '',
                  greeting: _getGreeting(),
                ),
                const SizedBox(height: 20),

                // Today's Summary
                BlocBuilder<ReminderCubit, ReminderState>(
                  builder: (context, reminderState) {
                    if (reminderState is ReminderLoaded) {
                      return _TodaySummaryCard(
                          logs: reminderState.logs);
                    }
                    return const SizedBox();
                  },
                ),
                const SizedBox(height: 20),

                // Next Reminder
                BlocBuilder<ReminderCubit, ReminderState>(
                  builder: (context, reminderState) {
                    if (reminderState is ReminderLoaded) {
                      final pending = reminderState.logs
                          .where((l) =>
                              l.status == IntakeStatus.pending)
                          .toList();
                      if (pending.isNotEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('الجرعة القادمة',
                                style: AppTextStyles.h3),
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

                // Pairing Card
                Text('الربط والمتابعة', style: AppTextStyles.h3),
                const SizedBox(height: 12),
                _ActionCard(
                  icon: Icons.link_rounded,
                  title: 'ربط مقدم الرعاية',
                  subtitle: 'اربط حسابك مع أحد أفراد العائلة',
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
        title: const Text('تسجيل الخروج',
            style: TextStyle(fontFamily: 'Cairo')),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟',
            style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء',
                style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().signOut();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('تسجيل الخروج',
                style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}

// Welcome Card
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
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
                    fontFamily: 'Cairo',
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite_rounded,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'اعتنِ بصحتك اليوم',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
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
              color: Colors.white.withOpacity(0.2),
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

// Today Summary Card
class _TodaySummaryCard extends StatelessWidget {
  final List<IntakeLogEntity> logs;

  const _TodaySummaryCard({required this.logs});

  @override
  Widget build(BuildContext context) {
    final taken =
        logs.where((l) => l.status == IntakeStatus.taken).length;
    final missed =
        logs.where((l) => l.status == IntakeStatus.missed).length;
    final pending =
        logs.where((l) => l.status == IntakeStatus.pending).length;
    final total = logs.length;

    if (total == 0) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ملخص اليوم', style: AppTextStyles.h3),
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
                      label: 'تم التناول',
                      value: taken,
                      total: total,
                      color: AppColors.success,
                      icon: Icons.check_circle_rounded,
                    ),
                  ),
                  Expanded(
                    child: _MiniStatItem(
                      label: 'فائتة',
                      value: missed,
                      total: total,
                      color: AppColors.error,
                      icon: Icons.cancel_rounded,
                    ),
                  ),
                  Expanded(
                    child: _MiniStatItem(
                      label: 'انتظار',
                      value: pending,
                      total: total,
                      color: AppColors.primary,
                      icon: Icons.access_time_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: total > 0 ? taken / total : 0,
                  backgroundColor: AppColors.divider,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.success),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'تناولت $taken من $total جرعة اليوم',
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
  final int total;
  final Color color;
  final IconData icon;

  const _MiniStatItem({
    required this.label,
    required this.value,
    required this.total,
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
            fontFamily: 'Cairo',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

// Next Reminder Card
class _NextReminderCard extends StatelessWidget {
  final IntakeLogEntity log;

  const _NextReminderCard({required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
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
            child: const Icon(
              Icons.medication_rounded,
              color: Colors.white,
              size: 28,
            ),
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
                      '${log.scheduledTime.hour.toString().padLeft(2, '0')}:${log.scheduledTime.minute.toString().padLeft(2, '0')}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'في الانتظار',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Action Card
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
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
            Icon(Icons.arrow_forward_ios_rounded,
                color: color, size: 16),
          ],
        ),
      ),
    );
  }
}