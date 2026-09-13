import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/lab_report.dart';
import '../../../shared/widgets/error_view.dart';
import '../cubit/lab_report_cubit.dart';
import 'lab_report_detail_page.dart';
import 'upload_lab_report_page.dart';

class LabReportsListPage extends StatefulWidget {
  final String patientId;
  final List<String> chronicConditions;

  const LabReportsListPage({
    super.key,
    required this.patientId,
    required this.chronicConditions,
  });

  @override
  State<LabReportsListPage> createState() => _LabReportsListPageState();
}

class _LabReportsListPageState extends State<LabReportsListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LabReportCubit>().loadPatientReports(
            patientId: widget.patientId,
            chronicDiseases: widget.chronicConditions,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'تقاريري الطبية والتحاليل',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo_rounded),
            tooltip: 'مسح تقرير جديد',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<LabReportCubit>(),
                    child: UploadLabReportPage(
                      patientId: widget.patientId,
                      chronicConditions: widget.chronicConditions,
                    ),
                  ),
                ),
              );
              if (result == true && context.mounted) {
                context.read<LabReportCubit>().loadPatientReports(
                      patientId: widget.patientId,
                      chronicDiseases: widget.chronicConditions,
                    );
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<LabReportCubit, LabReportState>(
        builder: (context, state) {
          if (state is LabReportLoading) {
            return const LoadingView();
          }

          if (state is LabReportError) {
            return ErrorView(
              message: state.message,
              icon: Icons.document_scanner_outlined,
              onRetry: () => context.read<LabReportCubit>().loadPatientReports(
                    patientId: widget.patientId,
                    chronicDiseases: widget.chronicConditions,
                  ),
            );
          }

          if (state is LabReportLoaded) {
            if (state.reports.isEmpty) {
              return _EmptyLabReportsView(
                patientId: widget.patientId,
                chronicConditions: widget.chronicConditions,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.reports.length,
              itemBuilder: (context, index) {
                return _LabReportCard(
                  report: state.reports[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LabReportDetailPage(
                          report: state.reports[index],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }

          return _EmptyLabReportsView(
            patientId: widget.patientId,
            chronicConditions: widget.chronicConditions,
          );
        },
      ),
    );
  }
}

class _EmptyLabReportsView extends StatelessWidget {
  final String patientId;
  final List<String> chronicConditions;

  const _EmptyLabReportsView({
    required this.patientId,
    required this.chronicConditions,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.analytics_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'لا توجد تقارير تحاليل مسجلة',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'قم بتصوير ورقة التحليل ليقوم الذكاء الاصطناعي بقراءتها وشرح نتائجها بوضوح.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<LabReportCubit>(),
                      child: UploadLabReportPage(
                        patientId: patientId,
                        chronicConditions: chronicConditions,
                      ),
                    ),
                  ),
                );
                if (result == true && context.mounted) {
                  context.read<LabReportCubit>().loadPatientReports(
                        patientId: patientId,
                        chronicDiseases: chronicConditions,
                      );
                }
              },
              icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
              label: const Text(
                'تصوير تحليل الآن ✨',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabReportCard extends StatelessWidget {
  final LabReportEntity report;
  final VoidCallback onTap;

  const _LabReportCard({
    required this.report,
    required this.onTap,
  });

  bool get _hasAbnormalities =>
      report.biomarkers.any((b) => b.status != BiomarkerStatus.normal);

  @override
  Widget build(BuildContext context) {
    final statusColor = _hasAbnormalities ? AppColors.warning : AppColors.success;
    final statusText = _hasAbnormalities ? 'يتطلب انتباه' : 'سليم وطبيعي';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: statusColor.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        onTap: onTap,
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            _hasAbnormalities
                ? Icons.warning_amber_rounded
                : Icons.verified_user_rounded,
            color: statusColor,
            size: 28,
          ),
        ),
        title: Text(
          report.title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'نوع التحليل: ${report.reportType}',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'التاريخ: ${report.reportDate.day}/${report.reportDate.month}/${report.reportDate.year}',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ),
      ),
    );
  }
}
