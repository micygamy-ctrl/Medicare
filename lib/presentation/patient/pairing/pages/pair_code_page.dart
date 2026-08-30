import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/pair.dart';
import '../cubit/pairing_cubit.dart';

class PairCodePage extends StatefulWidget {
  final String patientId;
  final String patientName;

  const PairCodePage({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<PairCodePage> createState() => _PairCodePageState();
}

class _PairCodePageState extends State<PairCodePage> {
  @override
  void initState() {
    super.initState();
    context.read<PairingCubit>().checkExistingPair(widget.patientId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ربط مقدم الرعاية'),
        backgroundColor: AppColors.surface,
      ),
      body: BlocConsumer<PairingCubit, PairingState>(
        listener: (context, state) {
          if (state is PairingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
          if (state is PairingRevoked) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إلغاء الارتباط بنجاح'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PairingLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is PairingAlreadyPaired) {
            return _AlreadyPairedView(
              pair: state.pair,
              onRevoke: () => context
                  .read<PairingCubit>()
                  .revokePair(state.pair.id),
            );
          }

          if (state is PairingCodeGenerated) {
            return _CodeGeneratedView(code: state.code);
          }

          // Initial State
          return _InitialView(
            onGenerate: () => context
                .read<PairingCubit>()
                .generateCode(widget.patientId),
          );
        },
      ),
    );
  }
}

// View 1 — لما مفيش كود
class _InitialView extends StatelessWidget {
  final VoidCallback onGenerate;

  const _InitialView({required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.link_rounded,
              size: 52,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'ربط مقدم الرعاية',
            style: AppTextStyles.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'ولّد كود مؤقت وشاركه مع مقدم الرعاية\nالكود صالح لمدة 24 ساعة',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onGenerate,
              child: const Text('توليد الكود'),
            ),
          ),
        ],
      ),
    );
  }
}

// View 2 — لما الكود اتولّد
class _CodeGeneratedView extends StatelessWidget {
  final String code;

  const _CodeGeneratedView({required this.code});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 72,
            color: AppColors.success,
          ),
          const SizedBox(height: 24),
          const Text('كود الربط', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text(
            'شارك هذا الكود مع مقدم الرعاية',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          // الكود
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم نسخ الكود'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 20,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    code,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 8,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.copy_rounded,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'اضغط على الكود لنسخه',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 32),

          // Expiry Notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'الكود صالح لمدة 24 ساعة',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// View 3 — لما في pair موجود
class _AlreadyPairedView extends StatelessWidget {
  final PairEntity pair;
  final VoidCallback onRevoke;

  const _AlreadyPairedView({
    required this.pair,
    required this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.secondaryLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              size: 52,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 24),
          const Text('مرتبط مع', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text(
            pair.caregiverName,
            style: AppTextStyles.h3.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 32),

          // Revoke Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('إلغاء الارتباط'),
                    content: const Text(
                      'هل أنت متأكد من إلغاء الارتباط مع مقدم الرعاية؟',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('إلغاء'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          onRevoke();
                        },
                        child: const Text(
                          'تأكيد',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                foregroundColor: AppColors.error,
              ),
              child: const Text('إلغاء الارتباط'),
            ),
          ),
        ],
      ),
    );
  }
}