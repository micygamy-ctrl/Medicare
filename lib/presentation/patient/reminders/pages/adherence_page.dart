import 'package:flutter/material.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/intake_log.dart';
import '../../../../domain/repositories/i_intake_log_repository.dart';
import '../../../../core/di/injection.dart';

class AdherencePage extends StatefulWidget {
  final String patientId;

  const AdherencePage({super.key, required this.patientId});

  @override
  State<AdherencePage> createState() => _AdherencePageState();
}

class _AdherencePageState extends State<AdherencePage> {
  bool _isLoading = true;
  double _weeklyAdherence = 0;
  double _monthlyAdherence = 0;
  List<IntakeLogEntity> _recentLogs = [];
  Map<String, int> _weeklyStats = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final repo = getIt<IIntakeLogRepository>();

      final weekly = await repo.getAdherencePercentage(
        patientId: widget.patientId,
        days: 7,
      );

      final monthly = await repo.getAdherencePercentage(
        patientId: widget.patientId,
        days: 30,
      );

      final now = DateTime.now();
      final logs = await repo.getLogsByDateRange(
        patientId: widget.patientId,
        startDate: now.subtract(const Duration(days: 7)),
        endDate: now,
      );

      final Map<String, int> dailyTaken = {};
      for (final log in logs) {
        final day = _getDayName(log.scheduledTime.weekday);
        if (log.status == IntakeStatus.taken) {
          dailyTaken[day] = (dailyTaken[day] ?? 0) + 1;
        }
      }

      setState(() {
        _weeklyAdherence = weekly;
        _monthlyAdherence = monthly;
        _recentLogs = logs.take(10).toList();
        _weeklyStats = dailyTaken;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _getDayName(int weekday) {
    if (AppStrings.isAr) {
      switch (weekday) {
        case 1: return 'الإثنين';
        case 2: return 'الثلاثاء';
        case 3: return 'الأربعاء';
        case 4: return 'الخميس';
        case 5: return 'الجمعة';
        case 6: return 'السبت';
        case 7: return 'الأحد';
        default: return '';
      }
    } else {
      switch (weekday) {
        case 1: return 'Mon';
        case 2: return 'Tue';
        case 3: return 'Wed';
        case 4: return 'Thu';
        case 5: return 'Fri';
        case 6: return 'Sat';
        case 7: return 'Sun';
        default: return '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.adherenceTitle),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Cards
                    Row(
                      children: [
                        Expanded(
                          child: _AdherenceCard(
                            title: AppStrings.isAr ? 'الالتزام الأسبوعي' : 'Weekly Adherence',
                            percentage: _weeklyAdherence,
                            icon: Icons.calendar_view_week_rounded,
                            days: 7,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _AdherenceCard(
                            title: AppStrings.isAr ? 'الالتزام الشهري' : 'Monthly Adherence',
                            percentage: _monthlyAdherence,
                            icon: Icons.calendar_month_rounded,
                            days: 30,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Weekly Bar Chart
                    Text(AppStrings.isAr ? 'الالتزام هذا الأسبوع' : 'This Week Adherence', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    _WeeklyChart(stats: _weeklyStats),
                    const SizedBox(height: 24),

                    // Status Summary
                    Text(AppStrings.isAr ? 'ملخص الجرعات' : 'Doses Summary', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    _StatusSummary(logs: _recentLogs),
                    const SizedBox(height: 24),

                    // Recent Logs
                    Text(AppStrings.isAr ? 'آخر الجرعات' : 'Recent Doses', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    if (_recentLogs.isEmpty)
                      Center(
                        child: Text(
                          AppStrings.adherenceNoData,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    else
                      ..._recentLogs.map(
                        (log) => _LogItem(log: log),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

// Adherence Card
class _AdherenceCard extends StatelessWidget {
  final String title;
  final double percentage;
  final IconData icon;
  final int days;

  const _AdherenceCard({
    required this.title,
    required this.percentage,
    required this.icon,
    required this.days,
  });

  Color get _color {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 50) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 12),

          // Circular Progress
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: AppColors.divider,
                  valueColor: AlwaysStoppedAnimation<Color>(_color),
                  strokeWidth: 8,
                ),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Weekly Chart
class _WeeklyChart extends StatelessWidget {
  final Map<String, int> stats;

  const _WeeklyChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    final days = AppStrings.isAr
        ? ['الجمعة', 'الخميس', 'الأربعاء', 'الثلاثاء', 'الإثنين', 'الأحد', 'السبت']
        : ['Fri', 'Thu', 'Wed', 'Tue', 'Mon', 'Sun', 'Sat'];
    final dayKeys = AppStrings.isAr
        ? ['الجمعة', 'الخميس', 'الأربعاء', 'الثلاثاء', 'الإثنين', 'الأحد', 'السبت']
        : ['Fri', 'Thu', 'Wed', 'Tue', 'Mon', 'Sun', 'Sat'];

    final maxValue = stats.values.isEmpty
        ? 1
        : stats.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final day = dayKeys[index];
                final value = stats[day] ?? 0;
                final barHeight = maxValue == 0
                    ? 0.0
                    : (value / maxValue) * 100;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (value > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              value.toString(),
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        Container(
                          height: barHeight + 4,
                          decoration: BoxDecoration(
                            color: value > 0
                                ? AppColors.primary
                                : AppColors.divider,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          days[index],
                          style: AppTextStyles.caption,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// Status Summary
class _StatusSummary extends StatelessWidget {
  final List<IntakeLogEntity> logs;

  const _StatusSummary({required this.logs});

  @override
  Widget build(BuildContext context) {
    final taken = logs.where((l) => l.status == IntakeStatus.taken).length;
    final missed = logs.where((l) => l.status == IntakeStatus.missed).length;
    final pending = logs.where((l) => l.status == IntakeStatus.pending).length;

    return Row(
      children: [
        Expanded(
          child: _StatusBox(
            label: AppStrings.takenLabel,
            value: taken,
            color: AppColors.success,
            icon: Icons.check_circle_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatusBox(
            label: AppStrings.missedLabel,
            value: missed,
            color: AppColors.error,
            icon: Icons.cancel_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatusBox(
            label: AppStrings.pendingLabel,
            value: pending,
            color: AppColors.primary,
            icon: Icons.access_time_rounded,
          ),
        ),
      ],
    );
  }
}

class _StatusBox extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _StatusBox({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value.toString(),
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

// Log Item
class _LogItem extends StatelessWidget {
  final IntakeLogEntity log;

  const _LogItem({required this.log});

  Color get _color {
    switch (log.status) {
      case IntakeStatus.taken: return AppColors.success;
      case IntakeStatus.missed: return AppColors.error;
      case IntakeStatus.snoozed: return AppColors.warning;
      default: return AppColors.primary;
    }
  }

  String get _statusText {
    switch (log.status) {
      case IntakeStatus.taken: return AppStrings.takenLabel;
      case IntakeStatus.missed: return AppStrings.missedLabel;
      case IntakeStatus.snoozed: return AppStrings.snoozed;
      default: return AppStrings.pendingLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              log.status == IntakeStatus.taken
                  ? Icons.check_circle_rounded
                  : log.status == IntakeStatus.missed
                      ? Icons.cancel_rounded
                      : Icons.access_time_rounded,
              color: _color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.medicationName, style: AppTextStyles.label),
                Text(
                  '${log.scheduledTime.day}/${log.scheduledTime.month} — ${log.scheduledTime.hour.toString().padLeft(2, '0')}:${log.scheduledTime.minute.toString().padLeft(2, '0')}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _statusText,
              style: AppTextStyles.caption.copyWith(
                color: _color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}