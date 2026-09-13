import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/user.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../../domain/repositories/i_auth_repository.dart';
import '../../../core/di/injection.dart';

class CaregiverProfilePage extends StatelessWidget {
  final UserEntity user;

  const CaregiverProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('حسابي')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.secondary, Color(0xFF3730A3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_rounded,
                        color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.displayName,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'مقدم رعاية',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Account Settings
            _SettingsSection(
              title: 'الحساب',
              items: [
                _SettingsItem(
                  icon: Icons.phone_outlined,
                  title: 'رقم الهاتف',
                  subtitle: user.phone?.isNotEmpty == true
                      ? user.phone!
                      : 'اضغط لإضافة رقم هاتفك',
                  onTap: () => _editPhone(context),
                ),
                _SettingsItem(
                  icon: Icons.notifications_outlined,
                  title: 'الإشعارات',
                  subtitle: 'إدارة إشعارات المتابعة',
                  onTap: () => _showNotificationSettings(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // App Settings
            _SettingsSection(
              title: 'التطبيق',
              items: [
                _SettingsItem(
                  icon: Icons.info_outline_rounded,
                  title: 'عن التطبيق',
                  subtitle: 'Med Care v1.0.0',
                  onTap: () => _showAboutDialog(context),
                ),
                _SettingsItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'سياسة الخصوصية',
                  subtitle: 'اقرأ سياسة الخصوصية',
                  onTap: () => _showPrivacyPolicy(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => _confirmLogout(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Edit Phone
 void _editPhone(BuildContext context) {
  final controller = TextEditingController(text: user.phone ?? '');
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('رقم الهاتف',
          style: TextStyle(fontFamily: 'Cairo')),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.phone,
        textDirection: TextDirection.ltr,
        decoration: const InputDecoration(
          hintText: '+20 1XX XXX XXXX',
          prefixIcon:
              Icon(Icons.phone_outlined, color: AppColors.textHint),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('إلغاء',
              style: TextStyle(fontFamily: 'Cairo')),
        ),
        ElevatedButton(
          onPressed: () async {
            if (controller.text.isNotEmpty) {
              Navigator.pop(ctx);
              try {
                await getIt<IAuthRepository>().updateProfile(
                  userId: user.uid,
                  phone: controller.text.trim(),
                );
                if (context.mounted) {
                  await context.read<AuthCubit>().checkAuthState();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تحديث رقم الهاتف ✓'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('فشل في تحديث رقم الهاتف'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            }
          },
          child: const Text('حفظ',
              style: TextStyle(fontFamily: 'Cairo')),
        ),
      ],
    ),
  );
}

  // Notification Settings
  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _NotificationSettingsSheet(),
    );
  }

  // About Dialog
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.medical_services_rounded,
                  color: AppColors.primary, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Med Care',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'الإصدار 1.0.0',
              style: TextStyle(
                  fontFamily: 'Cairo', color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            const Text(
              'تطبيق متخصص في إدارة الأدوية ومتابعة صحة المرضى، يربط المريض بمقدم الرعاية لضمان الالتزام بالعلاج.',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('حسناً',
                style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  // Privacy Policy
  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'سياسة الخصوصية',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _PrivacySection(
                title: '1. جمع البيانات',
                content:
                    'نجمع فقط البيانات الضرورية لتشغيل التطبيق، بما في ذلك: معلومات الحساب، بيانات الأدوية، وسجلات الاستخدام.',
              ),
              _PrivacySection(
                title: '2. استخدام البيانات',
                content:
                    'تُستخدم البيانات فقط لتوفير خدمات التطبيق وتحسين تجربة المستخدم. لا نشارك بياناتك مع أطراف ثالثة.',
              ),
              _PrivacySection(
                title: '3. أمان البيانات',
                content:
                    'نستخدم تشفيراً متقدماً لحماية بياناتك. جميع البيانات مخزنة بأمان على خوادم Firebase.',
              ),
              _PrivacySection(
                title: '4. حقوقك',
                content:
                    'يحق لك الوصول إلى بياناتك أو تعديلها أو حذفها في أي وقت من خلال إعدادات التطبيق.',
              ),
              _PrivacySection(
                title: '5. التواصل',
                content:
                    'لأي استفسارات حول سياسة الخصوصية، يرجى التواصل معنا عبر البريد الإلكتروني.',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('فهمت',
                      style: TextStyle(fontFamily: 'Cairo')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Confirm Logout
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

// Notification Settings Sheet
class _NotificationSettingsSheet extends StatefulWidget {
  @override
  State<_NotificationSettingsSheet> createState() =>
      _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState
    extends State<_NotificationSettingsSheet> {
  bool _missedDoseAlert = true;
  bool _dailySummary = true;
  bool _lowAdherenceAlert = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'إعدادات الإشعارات',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _NotificationSwitch(
            title: 'تنبيه الجرعات الفائتة',
            subtitle: 'عند تفويت المريض لجرعة',
            value: _missedDoseAlert,
            onChanged: (v) => setState(() => _missedDoseAlert = v),
          ),
          _NotificationSwitch(
            title: 'ملخص يومي',
            subtitle: 'تقرير يومي عن حالة المريض',
            value: _dailySummary,
            onChanged: (v) => setState(() => _dailySummary = v),
          ),
          _NotificationSwitch(
            title: 'تنبيه انخفاض الالتزام',
            subtitle: 'عند انخفاض الالتزام عن 50%',
            value: _lowAdherenceAlert,
            onChanged: (v) => setState(() => _lowAdherenceAlert = v),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حفظ إعدادات الإشعارات'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text('حفظ',
                  style: TextStyle(fontFamily: 'Cairo')),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 14)),
      subtitle: Text(subtitle,
          style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: AppColors.textSecondary)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}

class _PrivacySection extends StatelessWidget {
  final String title;
  final String content;

  const _PrivacySection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.textSecondary,
              height: 1.6,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;

  const _SettingsSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 8),
          child: Text(title, style: AppTextStyles.label),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  item,
                  if (index < items.length - 1)
                    const Divider(height: 1, indent: 56, endIndent: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 14)),
      subtitle: Text(subtitle,
          style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: AppColors.textSecondary)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded,
          size: 14, color: AppColors.textHint),
    );
  }
}