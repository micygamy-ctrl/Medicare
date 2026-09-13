import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/primary_button.dart';
import '../cubit/lab_report_cubit.dart';

class UploadLabReportPage extends StatefulWidget {
  final String patientId;
  final List<String> chronicConditions;

  const UploadLabReportPage({
    super.key,
    required this.patientId,
    required this.chronicConditions,
  });

  @override
  State<UploadLabReportPage> createState() => _UploadLabReportPageState();
}

class _UploadLabReportPageState extends State<UploadLabReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String _selectedReportType = 'CBC (صورة دم كاملة)';
  File? _reportImage;

  final ImagePicker _picker = ImagePicker();

  final List<String> _reportTypes = [
    'CBC (صورة دم كاملة)',
    'تحليل سكر تراكمي / صائم (Glucose/HbA1c)',
    'تحليل دهون وكوليسترول (Lipid Profile)',
    'وظائف كلى (Kidney Function)',
    'وظائف كبد (Liver Function)',
    'تحليل طبي عام (General Lab)',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (picked != null) {
        setState(() => _reportImage = File(picked.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر اختيار/التقاط صورة التقرير'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _onUpload() {
    if (_reportImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('من فضلك التقط أو اختر صورة تقرير التحليل أولاً'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      context.read<LabReportCubit>().uploadAndAnalyze(
            patientId: widget.patientId,
            imageFile: _reportImage!,
            reportType: _selectedReportType,
            title: _titleController.text.trim(),
            patientChronicConditions: widget.chronicConditions,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LabReportCubit, LabReportState>(
      listener: (context, state) {
        if (state is LabReportUploadedSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحليل التقرير بنجاح بالذكاء الاصطناعي ✨'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        }
        if (state is LabReportError) {
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
            'رفع وتحليل تقرير جديد',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.surface,
        ),
        body: BlocBuilder<LabReportCubit, LabReportState>(
          builder: (context, state) {
            final isAnalyzing = state is LabReportAnalyzing;

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // AI Banner
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.success.withOpacity(0.4)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.auto_awesome_rounded,
                                  color: AppColors.success, size: 30),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'القارئ الذكي للتحاليل الطبية يقوم باستخراج قيم التحاليل وشرح نتائجك باللغة العربية البسيطة.',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Image Picker Frame
                        Text('صورة ورقة التحليل الطبية',
                            style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                              ),
                              builder: (ctx) => Container(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'مصدر تقرير التحليل',
                                      style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    const SizedBox(height: 16),
                                    ListTile(
                                      leading: const Icon(
                                          Icons.camera_alt_rounded,
                                          color: AppColors.primary),
                                      title: const Text('الكاميرا المباشرة',
                                          style: TextStyle(
                                              fontFamily: 'Cairo')),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        _pickImage(ImageSource.camera);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(
                                          Icons.photo_library_rounded,
                                          color: AppColors.primary),
                                      title: const Text('معرض الصور',
                                          style: TextStyle(
                                              fontFamily: 'Cairo')),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        _pickImage(ImageSource.gallery);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _reportImage != null
                                    ? AppColors.primary
                                    : AppColors.cardBorder,
                                width: _reportImage != null ? 2 : 1.5,
                              ),
                            ),
                            child: _reportImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: Stack(
                                      children: [
                                        Image.file(
                                          _reportImage!,
                                          width: double.infinity,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                          top: 10,
                                          right: 10,
                                          child: CircleAvatar(
                                            backgroundColor: Colors.black
                                                .withOpacity(0.6),
                                            child: IconButton(
                                              icon: const Icon(
                                                  Icons.close_rounded,
                                                  color: Colors.white),
                                              onPressed: () => setState(
                                                  () => _reportImage = null),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.document_scanner_rounded,
                                          size: 48,
                                          color: AppColors.primary),
                                      SizedBox(height: 12),
                                      Text(
                                        'اضغط لتصوير تقرير التحليل بالكاميرا',
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'تأكد من وضوح الأرقام والأسماء في الصورة',
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Report Type Selector
                        Text('نوع التحليل الطبي', style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedReportType,
                          decoration: const InputDecoration(),
                          items: _reportTypes
                              .map((t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(
                                      t,
                                      style: const TextStyle(
                                          fontFamily: 'Cairo', fontSize: 13),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedReportType = v!),
                        ),
                        const SizedBox(height: 16),

                        // Optional Title
                        Text('عنوان مخصص للتقرير (اختياري)',
                            style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            hintText: 'مثال: تحليل سكر مركز الشفاء - يناير',
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Submit Button
                        PrimaryButton(
                          label: 'بدء تحليل التقرير بالذكاء الاصطناعي ✨',
                          isLoading: isAnalyzing,
                          onPressed: isAnalyzing ? () {} : _onUpload,
                        ),
                      ],
                    ),
                  ),
                ),

                // AI Processing Loading Overlay
                if (isAnalyzing)
                  Container(
                    color: Colors.black.withOpacity(0.6),
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              (state as LabReportAnalyzing).statusMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'جاري قراءة القيم واستنتاج التوصيات الغذائية الحالية...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
