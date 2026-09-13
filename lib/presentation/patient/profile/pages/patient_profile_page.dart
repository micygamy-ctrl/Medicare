import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_language_cubit.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/user.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../shared/widgets/primary_button.dart';

class PatientProfilePage extends StatefulWidget {
  final UserEntity user;

  const PatientProfilePage({super.key, required this.user});

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _doctorController = TextEditingController();
  final _notesController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  DateTime? _dateOfBirth;
  String? _gender;
  BloodType? _bloodType;
  List<String> _chronicDiseases = [];
  List<String> _allergies = [];

  final _newDiseaseController = TextEditingController();
  final _newAllergyController = TextEditingController();

  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  final List<String> _commonDiseases = [
    'السكري',
    'ضغط الدم',
    'أمراض القلب',
    'الربو',
    'الكلى',
    'الكبد',
    'الغدة الدرقية',
    'هشاشة العظام'
  ];

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.user.phone ?? '';
    _doctorController.text = widget.user.doctorName ?? '';
    _notesController.text = widget.user.notes ?? '';
    _emergencyNameController.text = widget.user.emergencyContactName ?? '';
    _emergencyPhoneController.text = widget.user.emergencyContactPhone ?? '';
    _dateOfBirth = widget.user.dateOfBirth;
    _gender = widget.user.gender;
    _bloodType = widget.user.bloodType;
    _chronicDiseases = List.from(widget.user.chronicDiseases);
    _allergies = List.from(widget.user.allergies);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _doctorController.dispose();
    _notesController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _newDiseaseController.dispose();
    _newAllergyController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ??
          DateTime.now().subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  BloodType? _bloodTypeFromString(String value) {
    switch (value) {
      case 'A+':
        return BloodType.aPositive;
      case 'A-':
        return BloodType.aNegative;
      case 'B+':
        return BloodType.bPositive;
      case 'B-':
        return BloodType.bNegative;
      case 'AB+':
        return BloodType.abPositive;
      case 'AB-':
        return BloodType.abNegative;
      case 'O+':
        return BloodType.oPositive;
      case 'O-':
        return BloodType.oNegative;
      default:
        return null;
    }
  }

  String _bloodTypeToString(BloodType? type) {
    switch (type) {
      case BloodType.aPositive:
        return 'A+';
      case BloodType.aNegative:
        return 'A-';
      case BloodType.bPositive:
        return 'B+';
      case BloodType.bNegative:
        return 'B-';
      case BloodType.abPositive:
        return 'AB+';
      case BloodType.abNegative:
        return 'AB-';
      case BloodType.oPositive:
        return 'O+';
      case BloodType.oNegative:
        return 'O-';
      default:
        return 'غير محدد';
    }
  }

  void _onSave() async {
    if (_formKey.currentState!.validate()) {
      await context.read<AuthCubit>().updateProfile(
            userId: widget.user.uid,
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            dateOfBirth: _dateOfBirth,
            gender: _gender,
            bloodType: _bloodType,
            chronicDiseases: _chronicDiseases,
            allergies: _allergies,
            emergencyContactName: _emergencyNameController.text.trim().isEmpty
                ? null
                : _emergencyNameController.text.trim(),
            emergencyContactPhone: _emergencyPhoneController.text.trim().isEmpty
                ? null
                : _emergencyPhoneController.text.trim(),
            doctorName: _doctorController.text.trim().isEmpty
                ? null
                : _doctorController.text.trim(),
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ الملف الطبي بنجاح ✓'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ملفي الطبي'),
        actions: [
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.logout_rounded),
                onPressed: () => context.read<AuthCubit>().signOut(),
              );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              _ProfileHeader(user: widget.user),
              const SizedBox(height: 20),

              // Language Switcher Tile inside Profile Page
              BlocBuilder<AppLanguageCubit, AppLanguageState>(
                builder: (context, langState) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.secondary.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.language_rounded,
                                color: AppColors.secondary),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.menuLanguage,
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.secondary,
                                  ),
                                ),
                                Text(
                                  langState.isArabic
                                      ? 'اللغة الحالية: العربية'
                                      : 'Current Language: English',
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Switch(
                          value: !langState.isArabic,
                          activeColor: AppColors.secondary,
                          onChanged: (_) {
                            context.read<AppLanguageCubit>().toggleLanguage();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // القسم الأول — البيانات الشخصية
              _SectionTitle(
                  title: 'البيانات الشخصية',
                  icon: Icons.person_outline_rounded),
              const SizedBox(height: 12),

              // الهاتف
              Text('رقم الهاتف', style: AppTextStyles.label),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  hintText: '+20 1XX XXX XXXX',
                  prefixIcon:
                      Icon(Icons.phone_outlined, color: AppColors.textHint),
                ),
              ),
              const SizedBox(height: 16),

              // تاريخ الميلاد
              Text('تاريخ الميلاد', style: AppTextStyles.label),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDateOfBirth,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: AppColors.textHint),
                      const SizedBox(width: 12),
                      Text(
                        _dateOfBirth != null
                            ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year} (${widget.user.age ?? _calcAge()} سنة)'
                            : 'اختر تاريخ الميلاد',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: _dateOfBirth != null
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // الجنس
              Text('الجنس', style: AppTextStyles.label),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _GenderCard(
                      label: 'ذكر',
                      icon: Icons.male_rounded,
                      isSelected: _gender == 'male',
                      onTap: () => setState(() => _gender = 'male'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GenderCard(
                      label: 'أنثى',
                      icon: Icons.female_rounded,
                      isSelected: _gender == 'female',
                      onTap: () => setState(() => _gender = 'female'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // القسم الثاني — البيانات الطبية
              _SectionTitle(
                  title: 'البيانات الطبية',
                  icon: Icons.medical_information_outlined),
              const SizedBox(height: 12),

              // فصيلة الدم
              Text('فصيلة الدم', style: AppTextStyles.label),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _bloodTypes.map((type) {
                  final isSelected = _bloodTypeToString(_bloodType) == type;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _bloodType = _bloodTypeFromString(type)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.error.withOpacity(0.1)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.error
                              : AppColors.cardBorder,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.error
                              : AppColors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // الأمراض المزمنة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('الأمراض المزمنة', style: AppTextStyles.label),
                  TextButton.icon(
                    onPressed: () => _showAddDialog(
                      title: 'إضافة مرض',
                      controller: _newDiseaseController,
                      suggestions: _commonDiseases,
                      onAdd: (value) {
                        if (!_chronicDiseases.contains(value)) {
                          setState(() => _chronicDiseases.add(value));
                        }
                      },
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('إضافة'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_chronicDiseases.isEmpty)
                _EmptyChip(label: 'لا توجد أمراض مزمنة مسجلة')
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _chronicDiseases
                      .map((disease) => _RemovableChip(
                            label: disease,
                            color: AppColors.warning,
                            onRemove: () => setState(
                                () => _chronicDiseases.remove(disease)),
                          ))
                      .toList(),
                ),
              const SizedBox(height: 16),

              // الحساسية
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('الحساسية من أدوية', style: AppTextStyles.label),
                  TextButton.icon(
                    onPressed: () => _showAddDialog(
                      title: 'إضافة حساسية',
                      controller: _newAllergyController,
                      suggestions: const [
                        'البنسلين',
                        'الأسبرين',
                        'الإيبوبروفين',
                        'السلفا',
                        'الكودايين'
                      ],
                      onAdd: (value) {
                        if (!_allergies.contains(value)) {
                          setState(() => _allergies.add(value));
                        }
                      },
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('إضافة'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_allergies.isEmpty)
                _EmptyChip(label: 'لا توجد حساسية مسجلة')
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allergies
                      .map((allergy) => _RemovableChip(
                            label: allergy,
                            color: AppColors.error,
                            onRemove: () =>
                                setState(() => _allergies.remove(allergy)),
                          ))
                      .toList(),
                ),
              const SizedBox(height: 16),

              // الطبيب المعالج
              Text('الطبيب المعالج', style: AppTextStyles.label),
              const SizedBox(height: 8),
              TextFormField(
                controller: _doctorController,
                decoration: const InputDecoration(
                  hintText: 'اسم الطبيب المعالج',
                  prefixIcon: Icon(Icons.local_hospital_outlined,
                      color: AppColors.textHint),
                ),
              ),
              const SizedBox(height: 24),

              // القسم الثالث — الطوارئ
              _SectionTitle(
                  title: 'جهة الاتصال في الطوارئ',
                  icon: Icons.emergency_outlined),
              const SizedBox(height: 12),

              Text('الاسم', style: AppTextStyles.label),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emergencyNameController,
                decoration: const InputDecoration(
                  hintText: 'اسم شخص الطوارئ',
                  prefixIcon:
                      Icon(Icons.person_outline, color: AppColors.textHint),
                ),
              ),
              const SizedBox(height: 16),

              Text('رقم الهاتف', style: AppTextStyles.label),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emergencyPhoneController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  hintText: '+20 1XX XXX XXXX',
                  prefixIcon:
                      Icon(Icons.phone_outlined, color: AppColors.textHint),
                ),
              ),
              const SizedBox(height: 16),

              // ملاحظات
              Text('ملاحظات طبية', style: AppTextStyles.label),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'أي معلومات إضافية مهمة...',
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              PrimaryButton(
                label: 'حفظ الملف الطبي',
                onPressed: _onSave,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  int _calcAge() {
    if (_dateOfBirth == null) return 0;
    final now = DateTime.now();
    int age = now.year - _dateOfBirth!.year;
    if (now.month < _dateOfBirth!.month ||
        (now.month == _dateOfBirth!.month && now.day < _dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  void _showAddDialog({
    required String title,
    required TextEditingController controller,
    required List<String> suggestions,
    required Function(String) onAdd,
  }) {
    controller.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          top: 24,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.h3),
            const SizedBox(height: 16),
            // Suggestions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestions
                  .map((s) => GestureDetector(
                        onTap: () {
                          onAdd(s);
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary),
                          ),
                          child: Text(s,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.primary)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    decoration:
                        const InputDecoration(hintText: 'أو أضف يدوياً'),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      onAdd(controller.text.trim());
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(60, 52),
                  ),
                  child: const Text('إضافة'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Profile Header
class _ProfileHeader extends StatelessWidget {
  final UserEntity user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
                if (user.age != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${user.age} سنة',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Section Title
class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.h3),
      ],
    );
  }
}

// Gender Card
class _GenderCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.label,
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Removable Chip
class _RemovableChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onRemove;

  const _RemovableChip({
    required this.label,
    required this.color,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: color)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded, size: 16, color: color),
          ),
        ],
      ),
    );
  }
}

// Empty Chip
class _EmptyChip extends StatelessWidget {
  final String label;

  const _EmptyChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: AppColors.cardBorder, style: BorderStyle.solid),
      ),
      child: Text(label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint)),
    );
  }
}
