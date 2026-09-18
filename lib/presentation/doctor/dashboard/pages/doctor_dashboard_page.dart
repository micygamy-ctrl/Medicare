import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/user.dart';
import '../../patient_detail/pages/doctor_patient_detail_page.dart';
import '../../pairing/pages/doctor_pair_page.dart';

class DoctorDashboardPage extends StatefulWidget {
  final UserEntity doctor;

  const DoctorDashboardPage({super.key, required this.doctor});

  @override
  State<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends State<DoctorDashboardPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppStrings.isAr ? 'د.' : 'Dr.'} ${widget.doctor.displayName}',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              widget.doctor.specialization ?? AppStrings.doctorPatientsPanel,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
            tooltip: AppStrings.tabDoctorPairing,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorPairPage(doctor: widget.doctor),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Summary Bar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('pairs')
                    .where('doctorId', isEqualTo: widget.doctor.uid)
                    .where('status', isEqualTo: 'active')
                    .snapshots(),
                builder: (context, snapshot) {
                  final patientCount =
                      snapshot.hasData ? snapshot.data!.docs.length : 0;

                  return Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          title: AppStrings.registeredPatients,
                          value: '$patientCount',
                          icon: Icons.people_outline_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          title: AppStrings.averageAdherence,
                          value: '88%',
                          icon: Icons.check_circle_outline_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Search Bar & Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: InputDecoration(
                      hintText: AppStrings.searchPatientHint,
                      hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.textHint),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.myPatientsList,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.qr_code_rounded, size: 18),
                        label: Text(
                          AppStrings.linkNewPatient,
                          style: const TextStyle(
                              fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DoctorPairPage(doctor: widget.doctor),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Patient Stream List
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pairs')
                  .where('doctorId', isEqualTo: widget.doctor.uid)
                  .where('status', isEqualTo: 'active')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState(context);
                }

                final pairDocs = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: pairDocs.length,
                  itemBuilder: (context, index) {
                    final pairData =
                        pairDocs[index].data() as Map<String, dynamic>;
                    final patientId = pairData['patientId'] as String? ?? '';
                    final patientName =
                        pairData['patientName'] as String? ?? AppStrings.unknownPatient;

                    if (_searchQuery.isNotEmpty &&
                        !patientName
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase())) {
                      return const SizedBox.shrink();
                    }

                    return _buildPatientTile(
                      context,
                      patientId: patientId,
                      patientName: patientName,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientTile(
    BuildContext context, {
    required String patientId,
    required String patientName,
  }) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(patientId).get(),
      builder: (context, snapshot) {
        String subtitle = AppStrings.loading;
        String bloodTypeStr = '';
        List<String> chronicDiseases = [];

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          bloodTypeStr = data['bloodType'] ?? '';
          chronicDiseases = List<String>.from(data['chronicDiseases'] ?? []);
          if (chronicDiseases.isNotEmpty) {
            subtitle = AppStrings.chronicDiseasesLabel(chronicDiseases.join('، '));
          } else {
            subtitle = AppStrings.noChronicDiseases;
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primary.withOpacity(0.12),
              child: Text(
                patientName.isNotEmpty ? patientName[0].toUpperCase() : 'P',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    patientName,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (bloodTypeStr.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      bloodTypeStr,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('intakeLogs')
                      .where('patientId', isEqualTo: patientId)
                      .get(),
                  builder: (context, logSnapshot) {
                    double adherenceVal = 0.85; // Default if no logs
                    int pctInt = 85;

                    if (logSnapshot.hasData && logSnapshot.data!.docs.isNotEmpty) {
                      final logs = logSnapshot.data!.docs;
                      final takenCount = logs
                          .where((doc) =>
                              (doc.data() as Map<String, dynamic>)['status'] ==
                              'taken')
                          .length;
                      adherenceVal = takenCount / logs.length;
                      pctInt = (adherenceVal * 100).round();
                    }

                    final adhColor = adherenceVal >= 0.8
                        ? AppColors.success
                        : adherenceVal >= 0.5
                            ? AppColors.warning
                            : AppColors.error;

                    return Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: adherenceVal,
                              backgroundColor: AppColors.surfaceVariant,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(adhColor),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.adherencePct(pctInt.toString()),
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: adhColor,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: AppColors.textHint),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorPatientDetailPage(
                    patientId: patientId,
                    patientName: patientName,
                    doctor: widget.doctor,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(
            Icons.people_outline_rounded,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.noDocPatients,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.noDocPatientsHint,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.qr_code_rounded, color: Colors.white),
            label: Text(
              AppStrings.createLinkCode,
              style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorPairPage(doctor: widget.doctor),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
