import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../presentation/patient/pairing/cubit/pairing_cubit.dart';

class EnterPairCodePage extends StatefulWidget {
  final String caregiverId;
  final String caregiverName;

  const EnterPairCodePage({
    super.key,
    required this.caregiverId,
    required this.caregiverName,
  });

  @override
  State<EnterPairCodePage> createState() => _EnterPairCodePageState();
}

class _EnterPairCodePageState extends State<EnterPairCodePage> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onPair() {
    if (_formKey.currentState!.validate()) {
      context.read<PairingCubit>().pairWithCode(
            code: _codeController.text.trim(),
            caregiverId: widget.caregiverId,
            caregiverName: widget.caregiverName,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.linkWithPatient),
        backgroundColor: AppColors.surface,
      ),
      body: BlocConsumer<PairingCubit, PairingState>(
        listener: (context, state) {
          if (state is PairingSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${AppStrings.pairSuccess} (${state.pair.patientName})',
                ),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context);
          }
          if (state is PairingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // Icon
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

                  Text(
                    AppStrings.enterPairCode,
                    style: AppTextStyles.h2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.enterPatientCodeSubtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Code Input
                  TextFormField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 8,
                      color: AppColors.primary,
                    ),
                    decoration: InputDecoration(
                      hintText: '000000',
                      hintStyle: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 8,
                        color: AppColors.textHint.withOpacity(0.5),
                      ),
                      counterText: '',
                      filled: true,
                      fillColor: AppColors.primaryLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.primaryDark,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.pairCodeInvalid;
                      }
                      if (value.length != 6) {
                        return AppStrings.pairCodeInvalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Pair Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed:
                          state is PairingLoading ? null : _onPair,
                      child: state is PairingLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(AppStrings.pairButton),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}