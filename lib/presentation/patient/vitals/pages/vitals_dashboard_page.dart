import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/vital_sign.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/primary_button.dart';
import '../cubit/vitals_cubit.dart';
import 'vitals_history_page.dart';

class VitalsDashboardPage extends StatefulWidget {
  final String patientId;

  const VitalsDashboardPage({super.key, required this.patientId});

  @override
  State<VitalsDashboardPage> createState() => _VitalsDashboardPageState();
}

class _VitalsDashboardPageState extends State<VitalsDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VitalsCubit>().loadPatientVitals(widget.patientId);
    });
  }

  void _showAddManualDialog(BuildContext context) {
    final sysController = TextEditingController(text: '120');
    final diaController = TextEditingController(text: '80');
    final hrController = TextEditingController(text: '75');
    final spO2Controller = TextEditingController(text: '98');
    final tempController = TextEditingController(text: '36.8');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.add_task_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'تسجيل قراءة حيوية جديدة',
              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: sysController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'ضغط انقباضي (Systolic)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: diaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'ضغط انبساطي (Diastolic)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: hrController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'نبضات القلب (BPM)'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: spO2Controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'أكسجين SpO2 (%)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: tempController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'الحرارة (°C)'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () {
              final sys = int.tryParse(sysController.text) ?? 120;
              final dia = int.tryParse(diaController.text) ?? 80;
              final hr = int.tryParse(hrController.text) ?? 75;
              final spo2 = int.tryParse(spO2Controller.text) ?? 98;
              final temp = double.tryParse(tempController.text) ?? 36.8;

              context.read<VitalsCubit>().addManualReading(
                    patientId: widget.patientId,
                    systolicBP: sys,
                    diastolicBP: dia,
                    heartRate: hr,
                    spO2: spo2,
                    temperature: temp,
                  );

              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حفظ القراءة الحيوية بنجاح ✓'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('حفظ', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'المؤشرات الحيوية والساعة الذكية',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'سجل القراءات',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<VitalsCubit>(),
                    child: VitalsHistoryPage(patientId: widget.patientId),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'إضافة يدوية',
            onPressed: () => _showAddManualDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<VitalsCubit, VitalsState>(
        builder: (context, state) {
          if (state is VitalsLoading || state is VitalsSyncing) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'جاري المزامنة مع الحساسات والساعة الذكية... ⌚',
                    style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          if (state is VitalsError) {
            return ErrorView(
              message: state.message,
              icon: Icons.monitor_heart_outlined,
              onRetry: () =>
                  context.read<VitalsCubit>().loadPatientVitals(widget.patientId),
            );
          }

          VitalSignEntity? latest;
          if (state is VitalsLoaded) {
            latest = state.latest;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Smartwatch Sync Action Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.watch_rounded,
                            color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الساعة الذكية متصلة ⌚',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'مزامنة فورية لنبضات القلب والضغط والأكسجين',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<VitalsCubit>()
                              .syncSmartwatch(widget.patientId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                        ),
                        child: const Text(
                          'مزامنة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Emergency Status Alert Box if critical
                if (latest != null && latest.status == VitalStatus.critical)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.error, width: 2),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: AppColors.error, size: 32),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'تنبيه طارئ: تم اكتشاف قراءات حيوية خارج المعدل الطبيعي! تم إشعار المرافق والطبيب فوراً.',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Section Title
                const Text(
                  'آخر القراءات الحيوية الحية',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),

                // 4 Main Metric Cards Grid
                Row(
                  children: [
                    Expanded(
                      child: _VitalMetricCard(
                        title: 'ضغط الدم',
                        value: latest != null
                            ? '${latest.systolicBP}/${latest.diastolicBP}'
                            : '120/80',
                        unit: 'mmHg',
                        icon: Icons.favorite_rounded,
                        color: Colors.red.shade600,
                        statusText: latest != null && latest.systolicBP >= 140
                            ? 'مرتفع'
                            : 'طبيعي',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _VitalMetricCard(
                        title: 'نبضات القلب',
                        value: latest != null ? '${latest.heartRate}' : '72',
                        unit: 'BPM',
                        icon: Icons.monitor_heart_rounded,
                        color: Colors.pink.shade500,
                        statusText: latest != null && latest.heartRate >= 100
                            ? 'سريع'
                            : 'طبيعي',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _VitalMetricCard(
                        title: 'نسبة الأكسجين',
                        value: latest != null ? '${latest.spO2}%' : '98%',
                        unit: 'SpO2',
                        icon: Icons.air_rounded,
                        color: Colors.blue.shade600,
                        statusText: latest != null && latest.spO2 <= 92
                            ? 'منخفض'
                            : 'ممتاز',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _VitalMetricCard(
                        title: 'درجة الحرارة',
                        value: latest != null
                            ? '${latest.temperature}°'
                            : '36.8°',
                        unit: 'Celsius',
                        icon: Icons.thermostat_rounded,
                        color: Colors.orange.shade700,
                        statusText: 'طبيعي',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Buttons
                PrimaryButton(
                  label: 'عرض سجل القراءات والرسوم البيانية 📊',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<VitalsCubit>(),
                          child: VitalsHistoryPage(patientId: widget.patientId),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _VitalMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final String statusText;

  const _VitalMetricCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$title ($unit)',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
