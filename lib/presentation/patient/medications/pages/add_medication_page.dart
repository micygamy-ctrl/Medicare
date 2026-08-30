import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/medication.dart';
import '../../../shared/widgets/primary_button.dart';
import '../cubit/medication_cubit.dart';

class AddMedicationPage extends StatefulWidget {
  final String patientId;
  final String createdBy;

  const AddMedicationPage({
    super.key,
    required this.patientId,
    required this.createdBy,
  });

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameArController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();

  MedicationForm _selectedForm = MedicationForm.tablet;
  String _selectedUnit = 'mg';
  MedicationFrequency _selectedFrequency = MedicationFrequency.daily;
  List<TimeOfDay> _selectedTimes = [const TimeOfDay(hour: 8, minute: 0)];
  DateTime _startDate = DateTime.now();

  // Visual Properties for Elderly & Illiterate Users
  String? _boxImagePath;
  String _selectedColorHex = 'E53935'; // Default Red

  final ImagePicker _picker = ImagePicker();

  final List<String> _units = ['mg', 'ml', 'g', 'IU', 'قرص', 'كبسولة'];

  final List<Map<String, String>> _boxColors = [
    {'name': 'أحمر', 'hex': 'E53935'},
    {'name': 'أزرق', 'hex': '1E88E5'},
    {'name': 'أخضر', 'hex': '4CAF50'},
    {'name': 'أصفر', 'hex': 'FDD835'},
    {'name': 'برتقالي', 'hex': 'FB8C00'},
    {'name': 'بنفسجي', 'hex': '8E24AA'},
    {'name': 'سماوي', 'hex': '00ACC1'},
    {'name': 'بني', 'hex': '6D4C41'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _pickBoxImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
      );
      if (image != null) {
        setState(() => _boxImagePath = image.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر التقاط/اختيار الصورة'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _timeToString(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTimes[index],
    );
    if (picked != null) {
      setState(() => _selectedTimes[index] = picked);
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      if (_selectedTimes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('من فضلك أضف موعد واحد على الأقل'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      context.read<MedicationCubit>().addMedication(
            patientId: widget.patientId,
            name: _nameController.text.trim(),
            nameAr: _nameArController.text.trim(),
            dosage: _dosageController.text.trim(),
            unit: _selectedUnit,
            form: _selectedForm,
            instructions: _instructionsController.text.trim(),
            startDate: _startDate,
            createdBy: widget.createdBy,
            times: _selectedTimes.map(_timeToString).toList(),
            frequency: _selectedFrequency,
            boxImageUrl: _boxImagePath,
            boxColorHex: _selectedColorHex,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MedicationCubit, MedicationState>(
      listener: (context, state) {
        if (state is MedicationAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إضافة الدواء بنجاح ✓'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        }
        if (state is MedicationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'إضافة دواء جديد',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.surface,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Visual Setup Banner for Elderly & Illiterate
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.visibility_rounded, color: AppColors.primary, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'تخصيص الهوية البصرية لكبار السن والأميين (تصوير علبة الدواء واختيار لونها)',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Drug Box Camera / Photo Picker
                Text('صورة علبة الدواء (اختياري)', style: AppTextStyles.label),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'التقاط/اختيار صورة علبة الدواء',
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            ListTile(
                              leading: const Icon(Icons.camera_alt_rounded,
                                  color: AppColors.primary),
                              title: const Text('الكاميرا المباشرة',
                                  style: TextStyle(fontFamily: 'Cairo')),
                              onTap: () {
                                Navigator.pop(context);
                                _pickBoxImage(ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library_rounded,
                                  color: AppColors.primary),
                              title: const Text('معرض الصور',
                                  style: TextStyle(fontFamily: 'Cairo')),
                              onTap: () {
                                Navigator.pop(context);
                                _pickBoxImage(ImageSource.gallery);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 130,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _boxImagePath != null
                            ? AppColors.primary
                            : AppColors.cardBorder,
                        width: _boxImagePath != null ? 2 : 1,
                      ),
                    ),
                    child: _boxImagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Stack(
                              children: [
                                Image.file(
                                  File(_boxImagePath!),
                                  width: double.infinity,
                                  height: 130,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black.withOpacity(0.6),
                                    child: IconButton(
                                      icon: const Icon(Icons.close_rounded,
                                          color: Colors.white, size: 18),
                                      onPressed: () =>
                                          setState(() => _boxImagePath = null),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_rounded,
                                  size: 36, color: AppColors.textHint),
                              SizedBox(height: 8),
                              Text(
                                'اضغط لتصوير علبة الدواء الحقيقية',
                                style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Color Swatch Selector
                Text('لون علبة / شريط الدواء', style: AppTextStyles.label),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _boxColors.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final item = _boxColors[index];
                      final colorHex = item['hex']!;
                      final isSelected = _selectedColorHex == colorHex;
                      final color = Color(int.parse('0xFF$colorHex'));

                      return GestureDetector(
                        onTap: () => setState(() => _selectedColorHex = colorHex),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.transparent,
                              width: isSelected ? 3 : 0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: isSelected ? 8 : 4,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: isSelected
                              ? const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 24)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // اسم الدواء
                Text('اسم الدواء (إنجليزي)', style: AppTextStyles.label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    hintText: 'Paracetamol',
                    prefixIcon: Icon(Icons.medication_outlined,
                        color: AppColors.textHint),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'من فضلك أدخل اسم الدواء';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // اسم الدواء عربي
                Text('اسم الدواء (عربي)', style: AppTextStyles.label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameArController,
                  textDirection: TextDirection.rtl,
                  decoration: const InputDecoration(
                    hintText: 'باراسيتامول',
                    prefixIcon: Icon(Icons.medication_outlined,
                        color: AppColors.textHint),
                  ),
                ),
                const SizedBox(height: 16),

                // الجرعة والوحدة
                Text('الجرعة', style: AppTextStyles.label),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _dosageController,
                        keyboardType: TextInputType.number,
                        textDirection: TextDirection.ltr,
                        decoration: const InputDecoration(hintText: '500'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'أدخل الجرعة';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedUnit,
                        decoration: const InputDecoration(),
                        items: _units
                            .map((u) => DropdownMenuItem(
                                  value: u,
                                  child: Text(u),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedUnit = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // شكل الدواء
                Text('شكل الدواء', style: AppTextStyles.label),
                const SizedBox(height: 8),
                _FormSelector(
                  selected: _selectedForm,
                  onChanged: (form) => setState(() => _selectedForm = form),
                ),
                const SizedBox(height: 16),

                // تعليمات
                Text('تعليمات', style: AppTextStyles.label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _instructionsController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'مثال: تناول مع الطعام',
                  ),
                ),
                const SizedBox(height: 16),

                // تاريخ البداية
                Text('تاريخ البداية', style: AppTextStyles.label),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickStartDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
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
                          '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // مواعيد الجرعات
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('مواعيد الجرعات', style: AppTextStyles.label),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedTimes.add(
                            const TimeOfDay(hour: 12, minute: 0),
                          );
                        });
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('إضافة موعد'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ..._selectedTimes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final time = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.access_time_rounded,
                          color: AppColors.primary),
                      title: Text(
                        _timeToString(time),
                        style: AppTextStyles.label,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                color: AppColors.primary),
                            onPressed: () => _pickTime(index),
                          ),
                          if (_selectedTimes.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: AppColors.error),
                              onPressed: () {
                                setState(
                                    () => _selectedTimes.removeAt(index));
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 32),

                // زرار الحفظ
                BlocBuilder<MedicationCubit, MedicationState>(
                  builder: (context, state) {
                    return PrimaryButton(
                      label: 'حفظ الدواء والهوية البصرية',
                      isLoading: state is MedicationLoading,
                      onPressed: _onSave,
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Form Selector Widget
class _FormSelector extends StatelessWidget {
  final MedicationForm selected;
  final ValueChanged<MedicationForm> onChanged;

  const _FormSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final forms = [
      (MedicationForm.tablet, Icons.medication_rounded, 'قرص'),
      (MedicationForm.capsule, Icons.medication_outlined, 'كبسولة'),
      (MedicationForm.syrup, Icons.local_drink_outlined, 'شراب'),
      (MedicationForm.injection, Icons.vaccines_outlined, 'حقنة'),
      (MedicationForm.drops, Icons.water_drop_outlined, 'قطرة'),
      (MedicationForm.cream, Icons.sanitizer_outlined, 'كريم'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: forms.map((item) {
        final isSelected = selected == item.$1;
        return GestureDetector(
          onTap: () => onChanged(item.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryLight : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.cardBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.$2,
                  size: 18,
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  item.$3,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}