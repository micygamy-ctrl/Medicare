import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MedicalDisclaimerDialog extends StatelessWidget {
  final VoidCallback onAccept;
  final bool isMandatory;

  const MedicalDisclaimerDialog({
    super.key,
    required this.onAccept,
    this.isMandatory = true,
  });

  static Future<bool?> show(BuildContext context, {bool isMandatory = true}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: !isMandatory,
      builder: (context) => MedicalDisclaimerDialog(
        isMandatory: isMandatory,
        onAccept: () => Navigator.pop(context, true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !isMandatory,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.gavel_rounded,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              const Text(
                'إخلاء مسؤولية طبي وشروط الاستخدام',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Divider
              Divider(color: Colors.grey.shade200, height: 1),
              const SizedBox(height: 16),

              // Content Body
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBulletPoint(
                        title: 'أداة مساعدة وليست بديلاً عن الطبيب',
                        body:
                            'تطبيق Med Care وتوصيات الذكاء الاصطناعي هي أدوات مساعدة للتذكير والتوعية فقط. ولا يُعتبر التطبيق بديلاً عن الاستشارة الطبية أو التشخيص المباشر من قبل طبيب مرخص.',
                      ),
                      const SizedBox(height: 12),
                      _buildBulletPoint(
                        title: 'حالات الطوارئ الطبية',
                        body:
                            'في حالة الأعراض الحادة، أو الآلام الشديدة، أو الطوارئ الطبية، يرجى الاتصال فوراً بخدمة الإسعاف أو التوجه لأقرب مستشفى.',
                      ),
                      const SizedBox(height: 12),
                      _buildBulletPoint(
                        title: 'حماية البيانات والخصوصية (HIPAA & WHO Standards)',
                        body:
                            'يتم التزام أعلى معايير تشفير البيانات وحمايتها. لا يتم مشاركة بياناتك الطبية إلا مع المرافقين أو الأطباء الذين تمنحهم موافقة صريحة.',
                      ),
                      const SizedBox(height: 12),
                      _buildBulletPoint(
                        title: 'التأكد من الجرعات الطبية',
                        body:
                            'يرجى دائماً مراجعة النشرة الطبية المرفقة وتوجيهات الطبيب المعالج قبل تناول أي دواء.',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Accept Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: onAccept,
                  child: const Text(
                    'أوافق وأفهم الشروط الطبية',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint({required String title, required String body}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
