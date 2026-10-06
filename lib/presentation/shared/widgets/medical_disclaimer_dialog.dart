import 'package:flutter/material.dart';
import '../../../core/localization/app_strings.dart';
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
    return PopScope(
      canPop: !isMandatory,
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
                  color: AppColors.primary.withValues(alpha: 0.12),
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
              Text(
                AppStrings.disclaimerTitle,
                style: const TextStyle(
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
                        title: AppStrings.disclaimerBullet1Title,
                        body: AppStrings.disclaimerBullet1Body,
                      ),
                      const SizedBox(height: 12),
                      _buildBulletPoint(
                        title: AppStrings.disclaimerBullet2Title,
                        body: AppStrings.disclaimerBullet2Body,
                      ),
                      const SizedBox(height: 12),
                      _buildBulletPoint(
                        title: AppStrings.disclaimerBullet3Title,
                        body: AppStrings.disclaimerBullet3Body,
                      ),
                      const SizedBox(height: 12),
                      _buildBulletPoint(
                        title: AppStrings.disclaimerBullet4Title,
                        body: AppStrings.disclaimerBullet4Body,
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
                  child: Text(
                    AppStrings.disclaimerAccept,
                    style: const TextStyle(
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
