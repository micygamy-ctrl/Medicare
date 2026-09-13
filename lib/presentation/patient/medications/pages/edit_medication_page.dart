import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/medication.dart';
import '../../../shared/widgets/primary_button.dart';
import '../cubit/medication_cubit.dart';

class EditMedicationPage extends StatefulWidget {
  final MedicationEntity medication;

  const EditMedicationPage({super.key, required this.medication});

  @override
  State<EditMedicationPage> createState() => _EditMedicationPageState();
}

class _EditMedicationPageState extends State<EditMedicationPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _nameArController;
  late TextEditingController _dosageController;
  late TextEditingController _instructionsController;

  late MedicationForm _selectedForm;
  late String _selectedUnit;
  late MedicationFrequency _selectedFrequency;
  late List<TimeOfDay> _selectedTimes;
  late DateTime _startDate;

  // Visual Properties
  String? _boxImagePath;
  late String _selectedColorHex;

  final ImagePicker _picker = ImagePicker();

  final List<String> _units = ['mg', 'ml', 'g', 'IU', 'قرص', 'كبسولة'];

  final List<Map<String, String>> _boxColors = [
    {'nameKey': 'red',    'hex': 'E53935'},
    {'nameKey': 'blue',   'hex': '1E88E5'},
    {'nameKey': 'green',  'hex': '4CAF50'},
    {'nameKey': 'yellow', 'hex': 'FDD835'},
    {'nameKey': 'orange', 'hex': 'FB8C00'},
    {'nameKey': 'purple', 'hex': '8E24AA'},
    {'nameKey': 'cyan',   'hex': '00ACC1'},
    {'nameKey': 'brown',  'hex': '6D4C41'},
  ];

  String _colorName(String key) {
    switch (key) {
      case 'red':    return AppStrings.colorRed;
      case 'blue':   return AppStrings.colorBlue;
      case 'green':  return AppStrings.colorGreen;
      case 'yellow': return AppStrings.colorYellow;
      case 'orange': return AppStrings.colorOrange;
      case 'purple': return AppStrings.colorPurple;
      case 'cyan':   return AppStrings.colorCyan;
      case 'brown':  return AppStrings.colorBrown;
      default:       return key;
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medication.name);
    _nameArController = TextEditingController(text: widget.medication.nameAr);
    _dosageController = TextEditingController(text: widget.medication.dosage);
    _instructionsController =
        TextEditingController(text: widget.medication.instructions);
    _selectedForm = widget.medication.form;
    _selectedUnit = _units.contains(widget.medication.unit)
        ? widget.medication.unit
        : 'mg';
    _selectedFrequency = widget.medication.schedules.isNotEmpty
        ? widget.medication.schedules.first.frequency
        : MedicationFrequency.daily;
    _startDate = widget.medication.startDate;
    _boxImagePath = widget.medication.boxImageUrl;
    _selectedColorHex = widget.medication.boxColorHex ?? 'E53935';

    _selectedTimes = widget.medication.schedules.isNotEmpty
        ? widget.medication.schedules.first.times.map((t) {
            final parts = t.split(':');
            return TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
          }).toList()
        : [const TimeOfDay(hour: 8, minute: 0)];
  }

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
        SnackBar(
          content: Text(AppStrings.drugBoxPickError),
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
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final updatedMedication = widget.medication.copyWith(
        name: _nameController.text.trim(),
        nameAr: _nameArController.text.trim(),
        dosage: _dosageController.text.trim(),
        unit: _selectedUnit,
        form: _selectedForm,
        instructions: _instructionsController.text.trim(),
        startDate: _startDate,
        boxImageUrl: _boxImagePath,
        boxColorHex: _selectedColorHex,
        schedules: [
          ScheduleEntity(
            id: widget.medication.schedules.isNotEmpty
                ? widget.medication.schedules.first.id
                : DateTime.now().millisecondsSinceEpoch.toString(),
            times: _selectedTimes.map(_timeToString).toList(),
            frequency: _selectedFrequency,
            daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
            reminderMinutesBefore: 15,
          ),
        ],
      );

      context.read<MedicationCubit>().updateMedication(updatedMedication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MedicationCubit, MedicationState>(
      listener: (context, state) {
        if (state is MedicationUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.medicationUpdated),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
        if (state is MedicationError) {
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
        appBar: AppBar(title: Text(AppStrings.editMedication)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Visual Box Image Picker
                Text(AppStrings.drugBoxPhotoLabel, style: AppTextStyles.label),
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
                            Text(
                              AppStrings.drugBoxPickSheet,
                              style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            ListTile(
                              leading: const Icon(Icons.camera_alt_rounded,
                                  color: AppColors.primary),
                              title: Text(AppStrings.drugBoxCamera,
                                  style: const TextStyle(fontFamily: 'Cairo')),
                              onTap: () {
                                Navigator.pop(context);
                                _pickBoxImage(ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library_rounded,
                                  color: AppColors.primary),
                              title: Text(AppStrings.drugBoxGallery,
                                  style: const TextStyle(fontFamily: 'Cairo')),
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
                                _boxImagePath!.startsWith('http')
                                    ? Image.network(
                                        _boxImagePath!,
                                        width: double.infinity,
                                        height: 130,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        File(_boxImagePath!),
                                        width: double.infinity,
                                        height: 130,
                                        fit: BoxFit.cover,
                                      ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: CircleAvatar(
                                    backgroundColor:
                                        Colors.black.withOpacity(0.6),
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
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_a_photo_rounded,
                                  size: 36, color: AppColors.textHint),
                              const SizedBox(height: 8),
                              Text(
                                AppStrings.drugBoxPickPrompt,
                                style: const TextStyle(
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
                Text(AppStrings.drugBoxColorLabel, style: AppTextStyles.label),
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

                      return Tooltip(
                        message: _colorName(item['nameKey']!),
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedColorHex = colorHex),
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
                            ),
                            child: isSelected
                                ? const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 24)
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Drug name (English)
                Text(AppStrings.medNameEn, style: AppTextStyles.label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    hintText: 'Paracetamol',
                    prefixIcon: Icon(Icons.medication_outlined,
                        color: AppColors.textHint),
                  ),
                  validator: (value) =>
                      value?.isEmpty == true ? AppStrings.enterMedName : null,
                ),
                const SizedBox(height: 16),

                // Drug name (Arabic)
                Text(AppStrings.medNameAr, style: AppTextStyles.label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameArController,
                  textDirection: TextDirection.rtl,
                  decoration: const InputDecoration(
                    hintText: 'باراسيتامول',
                  ),
                ),
                const SizedBox(height: 16),

                // Dosage + unit
                Text(AppStrings.dosageLabel, style: AppTextStyles.label),
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
                        validator: (value) =>
                            value?.isEmpty == true ? AppStrings.enterDosage : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedUnit,
                        decoration: const InputDecoration(),
                        items: _units
                            .map((u) =>
                                DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedUnit = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Drug form
                Text(AppStrings.formLabel, style: AppTextStyles.label),
                const SizedBox(height: 8),
                _FormSelector(
                  selected: _selectedForm,
                  onChanged: (form) => setState(() => _selectedForm = form),
                ),
                const SizedBox(height: 16),

                // Instructions
                Text(AppStrings.instructionsLabel, style: AppTextStyles.label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _instructionsController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: AppStrings.instructionsHint,
                  ),
                ),
                const SizedBox(height: 16),

                // Start date
                Text(AppStrings.startDateLabel, style: AppTextStyles.label),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickStartDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
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

                // Dose times
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppStrings.doseTimesLabel, style: AppTextStyles.label),
                    TextButton.icon(
                      onPressed: () => setState(() => _selectedTimes
                          .add(const TimeOfDay(hour: 12, minute: 0))),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(AppStrings.addDoseTime),
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
                      title: Text(_timeToString(time),
                          style: AppTextStyles.label),
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
                              onPressed: () => setState(
                                  () => _selectedTimes.removeAt(index)),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 32),

                BlocBuilder<MedicationCubit, MedicationState>(
                  builder: (context, state) {
                    return PrimaryButton(
                      label: AppStrings.save,
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

// Form Selector
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
      (MedicationForm.tablet,    Icons.medication_rounded,    AppStrings.formTablet),
      (MedicationForm.capsule,   Icons.medication_outlined,   AppStrings.formCapsule),
      (MedicationForm.syrup,     Icons.local_drink_outlined,  AppStrings.formSyrup),
      (MedicationForm.injection, Icons.vaccines_outlined,     AppStrings.formInjection),
      (MedicationForm.drops,     Icons.water_drop_outlined,   AppStrings.formDrops),
      (MedicationForm.cream,     Icons.sanitizer_outlined,    AppStrings.formCream),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                Icon(item.$2,
                    size: 18,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  item.$3,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
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