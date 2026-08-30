import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        const SnackBar(
          content: Text('من فضلك أدخل كود المريض الصحيح'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Find patient with matching user ID prefix or pair code
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'patient')
          .get();

      DocumentSnapshot? matchedPatientDoc;
      for (final doc in querySnapshot.docs) {
        if (doc.id.toUpperCase().startsWith(inputCode) ||
            doc.id.toUpperCase() == inputCode) {
          matchedPatientDoc = doc;
          break;
        }
      }

      if (matchedPatientDoc == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لم يتم العثور على مريض بهذا الكود'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final patientData = matchedPatientDoc.data() as Map<String, dynamic>;
      final patientId = matchedPatientDoc.id;
      final patientName = patientData['displayName'] ?? 'المريض';

      // Create pair document in Firestore
      final pairRef = FirebaseFirestore.instance.collection('pairs').doc();
      await pairRef.set({
        'id': pairRef.id,
        'doctorId': widget.doctor.uid,
        'doctorName': widget.doctor.displayName,
        'patientId': patientId,
        'patientName': patientName,
        'status': 'active',
        'createdAt': Timestamp.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم ربط المريض ($patientName) بنجاح!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء عملية الربط، حاول مرة أخرى'),
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
        title: const Text(
          'ربط مريض جديد',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
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
                  const Text(
                    'كود الطبيب الخاص بك',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'شارك هذا الكود مع المريض ليقوم بإدخاله في تطبيقه وربط حسابه بك:',
                    style: TextStyle(
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
                              const SnackBar(
                                content: Text('تم نسخ كود الربط!'),
                                duration: Duration(seconds: 2),
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'أو أدخل كود المريض المباشر',
                    style: TextStyle(
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
                  const Text(
                    'إدخال كود المريض',
                    style: TextStyle(
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
                      hintText: 'أدخل أول 6 أحرف من كود المريض',
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
                          : const Text(
                              'تأكيد ربط المريض',
                              style: TextStyle(
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
