import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/user.dart';

class DoctorPairPage extends StatefulWidget {
  final UserEntity doctor;

  const DoctorPairPage({super.key, required this.doctor});

  @override
  State<DoctorPairPage> createState() => _DoctorPairPageState();
}

class _DoctorPairPageState extends State<DoctorPairPage> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _generatedCode;

  @override
  void initState() {
    super.initState();
    _generateDoctorPairCode();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _generateDoctorPairCode() {
    // Generate a 6-character alphanumeric code
    final code = (widget.doctor.uid.substring(0, 6)).toUpperCase();
    setState(() => _generatedCode = code);
  }

  Future<void> _linkPatientByCode() async {
    final inputCode = _codeController.text.trim().toUpperCase();
    if (inputCode.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.pairCodeInvalid),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? patientId;
      String? patientName;

      // 1. Direct lookup in pairingCodes collection
      final codeDoc = await FirebaseFirestore.instance
          .collection('pairingCodes')
          .doc(inputCode)
          .get();

      if (codeDoc.exists) {
        final codeData = codeDoc.data() as Map<String, dynamic>;
        final expiresAt = (codeData['expiresAt'] as Timestamp?)?.toDate();
        final isUsed = codeData['isUsed'] == true;

        if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('انتهت صلاحية الكود'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }

        if (isUsed) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم استخدام هذا الكود من قبل'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }

        patientId = codeData['patientId'] as String?;
      } else {
        // 2. Direct lookup in users collection if full UID was provided
        final directUserDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(inputCode)
            .get();
        if (directUserDoc.exists &&
            directUserDoc.data()?['role'] == 'patient') {
          patientId = directUserDoc.id;
        }
      }

      if (patientId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.pairCodeInvalid),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // Fetch target patient name
      final patientDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(patientId)
          .get();
      if (patientDoc.exists) {
        patientName =
            (patientDoc.data() as Map<String, dynamic>)['displayName'] ??
                AppStrings.rolePatient;
      } else {
        patientName = AppStrings.rolePatient;
      }

      // Create pair document in Firestore securely
      final pairId = '${widget.doctor.uid}_$patientId';
      await FirebaseFirestore.instance.collection('pairs').doc(pairId).set({
        'id': pairId,
        'doctorId': widget.doctor.uid,
        'doctorName': widget.doctor.displayName,
        'patientId': patientId,
        'patientName': patientName,
        'status': 'active',
        'createdAt': Timestamp.now(),
      });

      // Mark pairing code as used if valid
      if (codeDoc.exists) {
        await FirebaseFirestore.instance
            .collection('pairingCodes')
            .doc(inputCode)
            .update({'isUsed': true});
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.pairSuccess} ($patientName)'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.unknownError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.doctorPairTitle,
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Code Generator Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.qr_code_2_rounded,
                    size: 56,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.doctorCodeTitle,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.doctorCodeSubtitle,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _generatedCode ?? '------',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded,
                              color: AppColors.primary),
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: _generatedCode ?? ''));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppStrings.pairCodeCopied),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Divider Or
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    AppStrings.orEnterPatientCode,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ],
            ),

            const SizedBox(height: 24),

            // Direct Patient Code Entry
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.enterPatientCodeTitle,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: AppStrings.enterPatientCodeHintText,
                      hintStyle: const TextStyle(fontFamily: 'Cairo'),
                      prefixIcon: const Icon(Icons.person_pin_rounded,
                          color: AppColors.textHint),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _isLoading ? null : _linkPatientByCode,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              AppStrings.confirmPatientLink,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
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
