import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../shared/widgets/medical_disclaimer_dialog.dart';
import '../../shared/widgets/primary_button.dart';
import '../cubit/auth_cubit.dart';
import '../../../domain/entities/user.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _specializationController = TextEditingController();
  final _licenseController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptedDisclaimer = false;
  UserRole _selectedRole = UserRole.patient;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _specializationController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (!_acceptedDisclaimer) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى الموافقة على إخلاء المسؤولية الطبي أولاً'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            displayName: _nameController.text.trim(),
            role: _selectedRole,
            specialization: _selectedRole == UserRole.doctor
                ? _specializationController.text.trim()
                : null,
            licenseNumber: _selectedRole == UserRole.doctor
                ? _licenseController.text.trim()
                : null,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.user.role == UserRole.patient) {
            Navigator.pushReplacementNamed(context, '/patient/main');
          } else if (state.user.role == UserRole.doctor) {
            Navigator.pushReplacementNamed(context, '/doctor/dashboard');
          } else {
            Navigator.pushReplacementNamed(context, '/caregiver/dashboard');
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 32, horizontal: 24),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'إنشاء حساب جديد',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'انضم إلى Med Care اليوم',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),

                // Form
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Role Selection
                        Text('أنا...', style: AppTextStyles.h3),
                        const SizedBox(height: 12),
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _RoleCard(
                                    title: 'مريض',
                                    subtitle: 'أتابع أدويتي',
                                    icon: Icons.person_outline_rounded,
                                    isSelected:
                                        _selectedRole == UserRole.patient,
                                    onTap: () => setState(() =>
                                        _selectedRole = UserRole.patient),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _RoleCard(
                                    title: 'مقدم رعاية',
                                    subtitle: 'أتابع مريضاً',
                                    icon: Icons.favorite_outline_rounded,
                                    isSelected:
                                        _selectedRole == UserRole.caregiver,
                                    onTap: () => setState(() =>
                                        _selectedRole = UserRole.caregiver),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _RoleCard(
                              title: 'طبيب معالج',
                              subtitle: 'متابعة المرضى وتحديث الروشتات الطبية',
                              icon: Icons.medical_information_outlined,
                              isSelected: _selectedRole == UserRole.doctor,
                              onTap: () => setState(
                                  () => _selectedRole = UserRole.doctor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Name
                        Text('الاسم الكامل', style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: 'أدخل اسمك الكامل',
                            prefixIcon: Icon(Icons.person_outline,
                                color: AppColors.textHint),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'من فضلك أدخل اسمك';
                            }
                            if (value.length < 3) {
                              return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email
                        Text('البريد الإلكتروني',
                            style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textDirection: TextDirection.ltr,
                          decoration: const InputDecoration(
                            hintText: 'example@email.com',
                            prefixIcon: Icon(Icons.email_outlined,
                                color: AppColors.textHint),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'من فضلك أدخل البريد الإلكتروني';
                            }
                            if (!value.contains('@')) {
                              return 'البريد الإلكتروني غير صحيح';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Doctor Fields (Specialization & License Number)
                        if (_selectedRole == UserRole.doctor) ...[
                          Text('التخصص الطبي', style: AppTextStyles.label),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _specializationController,
                            decoration: const InputDecoration(
                              hintText: 'مثال: باطنة، قلبيات، سكري',
                              prefixIcon: Icon(Icons.badge_outlined,
                                  color: AppColors.textHint),
                            ),
                            validator: (value) {
                              if (_selectedRole == UserRole.doctor &&
                                  (value == null || value.isEmpty)) {
                                return 'يرجى إدخال التخصص الطبي';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          Text('رقم الترخيص الطبي / النقابي',
                              style: AppTextStyles.label),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _licenseController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'أدخل رقم الترخيص النقابي',
                              prefixIcon: Icon(Icons.verified_outlined,
                                  color: AppColors.textHint),
                            ),
                            validator: (value) {
                              if (_selectedRole == UserRole.doctor &&
                                  (value == null || value.isEmpty)) {
                                return 'يرجى إدخال رقم الترخيص';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Password
                        Text('كلمة المرور', style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textDirection: TextDirection.ltr,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: AppColors.textHint),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.textHint,
                              ),
                              onPressed: () => setState(() =>
                                  _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'من فضلك أدخل كلمة المرور';
                            }
                            if (value.length < 6) {
                              return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password
                        Text('تأكيد كلمة المرور',
                            style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirm,
                          textDirection: TextDirection.ltr,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: AppColors.textHint),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.textHint,
                              ),
                              onPressed: () => setState(() =>
                                  _obscureConfirm = !_obscureConfirm),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'من فضلك أكد كلمة المرور';
                            }
                            if (value != _passwordController.text) {
                              return 'كلمة المرور غير متطابقة';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Medical Disclaimer Checkbox
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _acceptedDisclaimer,
                                activeColor: AppColors.primary,
                                onChanged: (val) => setState(() {
                                  _acceptedDisclaimer = val ?? false;
                                }),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    MedicalDisclaimerDialog.show(context,
                                            isMandatory: false)
                                        .then((accepted) {
                                      if (accepted == true) {
                                        setState(() =>
                                            _acceptedDisclaimer = true);
                                      }
                                    });
                                  },
                                  child: const Text.rich(
                                    TextSpan(
                                      text: 'أوافق على ',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 13,
                                        color: AppColors.textPrimary,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'إخلاء المسؤولية الطبي والشروط',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Register Button
                        BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, state) {
                            return PrimaryButton(
                              label: 'إنشاء الحساب',
                              isLoading: state is AuthLoading,
                              onPressed: _onRegister,
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'لديك حساب بالفعل؟',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'تسجيل الدخول',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Role Card
class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.15)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.label.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}