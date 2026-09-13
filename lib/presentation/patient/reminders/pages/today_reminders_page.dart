import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../domain/entities/intake_log.dart';
import '../cubit/reminder_cubit.dart';
import '../../../shared/widgets/error_view.dart';

class TodayRemindersPage extends StatefulWidget {
  final String patientId;

  const TodayRemindersPage({super.key, required this.patientId});

  @override
  State<TodayRemindersPage> createState() => _TodayRemindersPageState();
}

class _TodayRemindersPageState extends State<TodayRemindersPage> {
  @override
  void initState() {
    super.initState();
    context.read<ReminderCubit>().loadTodayReminders(widget.patientId);
  }

  String _getTodayDate() {
    final now = DateTime.now();
    final days = [
      '',
      AppStrings.pick('الإثنين', 'Monday'),
      AppStrings.pick('الثلاثاء', 'Tuesday'),
      AppStrings.pick('الأربعاء', 'Wednesday'),
      AppStrings.pick('الخميس', 'Thursday'),
      AppStrings.pick('الجمعة', 'Friday'),
      AppStrings.pick('السبت', 'Saturday'),
      AppStrings.pick('الأحد', 'Sunday')
    ];
    final months = [
      '',
      AppStrings.pick('يناير', 'January'),
      AppStrings.pick('فبراير', 'February'),
      AppStrings.pick('مارس', 'March'),
      AppStrings.pick('إبريل', 'April'),
      AppStrings.pick('مايو', 'May'),
      AppStrings.pick('يونيو', 'June'),
      AppStrings.pick('يوليو', 'July'),
      AppStrings.pick('أغسطس', 'August'),
      AppStrings.pick('سبتمبر', 'September'),
      AppStrings.pick('أكتوبر', 'October'),
      AppStrings.pick('نوفمبر', 'November'),
      AppStrings.pick('ديسمبر', 'December')
    ];
    return AppStrings.isAr
        ? '${days[now.weekday]}، ${now.day} ${months[now.month]}'
        : '${days[now.weekday]}, ${months[now.month]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          children: [
            Text(AppStrings.remindersTitle),
            Text(
              _getTodayDate(),
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: BlocConsumer<ReminderCubit, ReminderState>(
        listener: (context, state) {
          if (state is ReminderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ReminderLoading) {
            return const LoadingView();
          }

          if (state is ReminderError) {
            return ErrorView(
              message: state.message,
              icon: Icons.notifications_outlined,
              onRetry: () => context
                  .read<ReminderCubit>()
                  .loadTodayReminders(widget.patientId),
            );
          }

          if (state is ReminderLoaded) {
            if (state.logs.isEmpty) {
              return _EmptyRemindersView();
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.logs.length,
              itemBuilder: (context, index) {
                return _ReminderCard(
                  log: state.logs[index],
                  onTaken: () => context
                      .read<ReminderCubit>()
                      .markAsTaken(state.logs[index].id),
                  onMissed: () => context
                      .read<ReminderCubit>()
                      .markAsMissed(state.logs[index].id),
                );
              },
            );
          }

          return _EmptyRemindersView();
        },
      ),
    );
  }
}

// Empty State
class _EmptyRemindersView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.secondaryLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              size: 52,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(AppStrings.noRemindersToday, style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(
            AppStrings.addMedicationsToSeeReminders,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// Reminder Card with Illiteracy & Elderly Friendly Visual Indicators
class _ReminderCard extends StatelessWidget {
  final IntakeLogEntity log;
  final VoidCallback onTaken;
  final VoidCallback onMissed;

  const _ReminderCard({
    required this.log,
    required this.onTaken,
    required this.onMissed,
  });

  Color _getStatusColor() {
    switch (log.status) {
      case IntakeStatus.taken:
        return AppColors.success;
      case IntakeStatus.missed:
        return AppColors.error;
      case IntakeStatus.snoozed:
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  String _getStatusText() {
    switch (log.status) {
      case IntakeStatus.taken:
        return AppStrings.taken;
      case IntakeStatus.missed:
        return AppStrings.missed;
      case IntakeStatus.snoozed:
        return AppStrings.snoozed;
      default:
        return AppStrings.pending;
    }
  }

  IconData _getStatusIcon() {
    switch (log.status) {
      case IntakeStatus.taken:
        return Icons.check_circle_rounded;
      case IntakeStatus.missed:
        return Icons.cancel_rounded;
      case IntakeStatus.snoozed:
        return Icons.snooze_rounded;
      default:
        return Icons.medication_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPending = log.status == IntakeStatus.pending;
    final statusColor = _getStatusColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Visual Medication Icon / Status Badge
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor, width: 2),
                  ),
                  child: Icon(
                    _getStatusIcon(),
                    color: statusColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 14),

                // Medication Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.medicationName,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppStrings.doseTime(
                                '${log.scheduledTime.hour.toString().padLeft(2, '0')}:${log.scheduledTime.minute.toString().padLeft(2, '0')}'),
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            // Big High-Contrast Action Buttons for Pending Doses
            if (isPending) ...[
              const SizedBox(height: 16),
              Divider(color: Colors.grey.shade200, height: 1),
              const SizedBox(height: 14),
              Row(
                children: [
                  // Large Taken Button (Green)
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: onTaken,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.check_circle_rounded,
                            size: 22, color: Colors.white),
                        label: Text(
                          AppStrings.takeNow,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Skip Button
                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: onMissed,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(
                            color: AppColors.error, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      label: Text(
                        AppStrings.skip,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
