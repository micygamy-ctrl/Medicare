import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/user.dart';
import '../auth/cubit/auth_cubit.dart';
import '../shared/cubit/locale_cubit.dart';
import '../shared/widgets/medical_disclaimer_dialog.dart';
import 'dashboard/pages/doctor_dashboard_page.dart';

class DoctorMainPage extends StatefulWidget {
  const DoctorMainPage({super.key});

  @override
  State<DoctorMainPage> createState() => _DoctorMainPageState();
}

class _DoctorMainPageState extends State<DoctorMainPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final doctor = state.user;

        final pages = [
          DoctorDashboardPage(doctor: doctor),
          _buildDoctorProfilePage(context, doctor),
        ];

        return Scaffold(
          body: pages[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            selectedLabelStyle: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'Cairo',
            ),
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded),
                label: 'لوحة التحكم',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'الملف الشخصي',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDoctorProfilePage(BuildContext context, UserEntity doctor) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ملف الطبيب والإعدادات',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Doctor Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primary.withOpacity(0.15),
                    child: const Icon(
                      Icons.medical_information_rounded,
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'د. ${doctor.displayName}',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctor.specialization ?? 'طبيب معالج',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (doctor.licenseNumber != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'ترخيص رقم: ${doctor.licenseNumber}',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Language Switcher Tile
            BlocBuilder<LocaleCubit, Locale>(
              builder: (context, locale) {
                final isAr = locale.languageCode == 'ar';
                return ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  tileColor: Colors.white,
                  leading: const Icon(Icons.language_rounded,
                      color: AppColors.primary),
                  title: const Text(
                    'تغيير لغة التطبيق',
                    style: TextStyle(
                        fontFamily: 'Cairo', fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    isAr ? 'العربية' : 'English',
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  trailing: Switch(
                    value: !isAr,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      context
                          .read<LocaleCubit>()
                          .changeLocale(val ? 'en' : 'ar');
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // Medical Disclaimer Tile
            ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              tileColor: Colors.white,
              leading:
                  const Icon(Icons.gavel_rounded, color: AppColors.primary),
              title: const Text(
                'إخلاء المسؤولية الطبي والشروط',
                style:
                    TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'عرض معايير منظمة الصحة العالمية والخصوصية',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 12),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                MedicalDisclaimerDialog.show(context, isMandatory: false);
              },
            ),
            const SizedBox(height: 12),

            // Sign Out Tile
            ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              tileColor: Colors.red.shade50,
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text(
                'تسجيل الخروج',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              onTap: () {
                context.read<AuthCubit>().signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
