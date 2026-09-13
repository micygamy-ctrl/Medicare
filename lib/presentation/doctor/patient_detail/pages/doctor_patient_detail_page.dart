import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/repositories/i_lab_report_repository.dart';
import '../../../../domain/repositories/i_vitals_repository.dart';
import '../../../patient/lab_reports/cubit/lab_report_cubit.dart';
import '../../../patient/lab_reports/pages/lab_reports_list_page.dart';
import '../../../patient/vitals/cubit/vitals_cubit.dart';
import '../../../patient/vitals/pages/vitals_dashboard_page.dart';

class DoctorPatientDetailPage extends StatelessWidget {
  final String patientId;
  final String patientName;
  final UserEntity doctor;

  const DoctorPatientDetailPage({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'ملف المريض: $patientName',
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(patientId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'تعذر تحميل بيانات المريض',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final bloodType = data['bloodType'] ?? 'غير محدد';
          final gender = data['gender'] ?? 'غير محدد';
          final emergencyName = data['emergencyContactName'] ?? 'غير محدد';
          final emergencyPhone = data['emergencyContactPhone'] ?? 'غير محدد';
          final chronicDiseases = List<String>.from(data['chronicDiseases'] ?? []);
          final allergies = List<String>.from(data['allergies'] ?? []);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.primary.withOpacity(0.12),
                            child: Text(
                              patientName.isNotEmpty
                                  ? patientName[0].toUpperCase()
                                  : 'P',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  patientName,
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _buildChip('فصيلة الدم: $bloodType',
                                        Colors.red.shade700, Colors.red.shade50),
                                    const SizedBox(width: 8),
                                    _buildChip('الجنس: $gender',
                                        AppColors.primary, AppColors.primaryLight),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Medical Summary Card
                _buildSectionCard(
                  title: 'التاريخ الطبي والتشخيص',
                  icon: Icons.health_and_safety_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الأمراض المزمنة:',
                        style: TextStyle(
                            fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      chronicDiseases.isEmpty
                          ? const Text('لا توجد أمراض مزمنة مسجلة',
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  color: AppColors.textSecondary))
                          : Wrap(
                              spacing: 8,
                              children: chronicDiseases
                                  .map((disease) => Chip(
                                        label: Text(disease,
                                            style: const TextStyle(
                                                fontFamily: 'Cairo',
                                                fontSize: 12)),
                                        backgroundColor: AppColors.surfaceVariant,
                                      ))
                                  .toList(),
                            ),
                      const SizedBox(height: 14),
                      const Text(
                        'الحساسية الطبية والدوائية:',
                        style: TextStyle(
                            fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      allergies.isEmpty
                          ? const Text('لا توجد حساسية مسجلة',
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  color: AppColors.textSecondary))
                          : Wrap(
                              spacing: 8,
                              children: allergies
                                  .map((allergy) => Chip(
                                        label: Text(allergy,
                                            style: const TextStyle(
                                                fontFamily: 'Cairo',
                                                fontSize: 12,
                                                color: Colors.orange)),
                                        backgroundColor: Colors.orange.shade50,
                                      ))
                                  .toList(),
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Lab Reports Section Card for Doctor
                _buildSectionCard(
                  title: 'تحاليل المريض الطبية ومؤشرات الذكاء الاصطناعي',
                  icon: Icons.document_scanner_rounded,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تقارير التحاليل واستخراج الـ OCR التلقائي',
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'استعراض قيم الجلوكوز والهيموجلوبين ووظائف الكبد والكلى',
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.analytics_rounded, size: 18, color: Colors.white),
                        label: const Text(
                          'استعراض',
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (_) => LabReportCubit(
                                  getIt<ILabReportRepository>(),
                                ),
                                child: LabReportsListPage(
                                  patientId: patientId,
                                  chronicConditions: chronicDiseases,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Doctor Vitals Live Tracking Card
                _buildSectionCard(
                  title: 'المؤشرات الحيوية المباشرة (الضغط والنبض والأكسجين)',
                  icon: Icons.monitor_heart_rounded,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'سجل القراءات الحية من الساعة الذكية والحساسات',
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'متابعة انضباط ضغط الدم ومعدل النبضات اليومي',
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.favorite_rounded, size: 18, color: Colors.white),
                        label: const Text(
                          'مراقبة',
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (_) => VitalsCubit(
                                  getIt<IVitalsRepository>(),
                                ),
                                child: VitalsDashboardPage(
                                  patientId: patientId,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Emergency Contact Card
                _buildSectionCard(
                  title: 'جهة الطوارئ والمرافق',
                  icon: Icons.phone_in_talk_rounded,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'المرافق: $emergencyName',
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'الهاتف: $emergencyPhone',
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const Icon(Icons.emergency_rounded, color: Colors.red),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Medications Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'أدوية المريض الحالية والروشتة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded, color: Colors.white),
                      label: const Text(
                        'إضافة دواء',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/patient/medications/add',
                          arguments: {
                            'patientId': patientId,
                            'createdBy': doctor.uid,
                          },
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Stream Medication Docs
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('medications')
                      .where('patientId', isEqualTo: patientId)
                      .where('isDeleted', isEqualTo: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            'لم يتم إدخال أدوية لهذا المريض حتى الآن',
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                color: AppColors.textSecondary),
                          ),
                        ),
                      );
                    }

                    final medDocs = snapshot.data!.docs;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: medDocs.length,
                      itemBuilder: (context, index) {
                        final med =
                            medDocs[index].data() as Map<String, dynamic>;
                        final name = med['name'] ?? 'دواء';
                        final dosage = med['dosage'] ?? '';
                        final instructions = med['instructions'] ?? '';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: AppColors.primaryLight,
                              child: Icon(Icons.medication_rounded,
                                  color: AppColors.primary),
                            ),
                            title: Text(
                              '$name ($dosage)',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              instructions.isNotEmpty
                                  ? instructions
                                  : 'بدون تعليمات إضافية',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      },
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

  Widget _buildChip(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
