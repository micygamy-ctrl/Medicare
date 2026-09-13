import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../domain/entities/medication.dart';
import '../cubit/medication_cubit.dart';
import 'edit_medication_page.dart';
import '../../../../core/utils/notification_scheduler.dart';
import '../../../shared/widgets/error_view.dart';

class MedicationListPage extends StatefulWidget {
  final String patientId;

  const MedicationListPage({super.key, required this.patientId});

  @override
  State<MedicationListPage> createState() => _MedicationListPageState();
}

class _MedicationListPageState extends State<MedicationListPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicationCubit>().loadMedications(widget.patientId);
    });
  }

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
        title: Text(AppStrings.myMedications),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            tooltip: AppStrings.testNotification,
            onPressed: () async {
              final state = context.read<MedicationCubit>().state;
              if (state is MedicationLoaded && state.medications.isNotEmpty) {
                await NotificationScheduler.showTestNotification(
                  medicationName: state.medications.first.name,
                  time: state.medications.first.schedules.isNotEmpty
                      ? state.medications.first.schedules.first.times.first
                      : '08:00',
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppStrings.testNotificationSent),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                '/patient/medications/add',
                arguments: <String, dynamic>{
                  'patientId': widget.patientId,
                  'createdBy': widget.patientId,
                },
              );
              if (result == true && context.mounted) {
                context
                    .read<MedicationCubit>()
                    .loadMedications(widget.patientId);
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<MedicationCubit, MedicationState>(
        listener: (context, state) {
          if (state is MedicationDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppStrings.medicationDeleted),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.read<MedicationCubit>().loadMedications(widget.patientId);
          }
          if (state is MedicationUpdated) {
            context.read<MedicationCubit>().loadMedications(widget.patientId);
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
        builder: (context, state) {
          if (state is MedicationLoading) {
            return const LoadingView();
          }

          if (state is MedicationError) {
            return ErrorView(
              message: state.message,
              icon: Icons.medication_outlined,
              onRetry: () => context
                  .read<MedicationCubit>()
                  .loadMedications(widget.patientId),
            );
          }

          if (state is MedicationLoaded) {
            final filtered = state.medications
                .where((m) =>
                    m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    m.nameAr.contains(_searchQuery))
                .toList();

            return Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: AppStrings.medicationSearchHint,
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.textHint),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded,
                                  color: AppColors.textHint),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.cardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.cardBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),
                ),

                // Stats Bar
                if (state.medications.isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          AppStrings.medicationCount(filtered.length),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                // List
                Expanded(
                  child: filtered.isEmpty
                      ? _EmptyView(isSearching: _searchQuery.isNotEmpty)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            return _MedicationCard(
                              medication: filtered[index],
                              onDelete: () => _confirmDelete(
                                context,
                                filtered[index],
                              ),
                              onEdit: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<MedicationCubit>(),
                                    child: EditMedicationPage(
                                      medication: filtered[index],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const _EmptyView(isSearching: false);
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, MedicationEntity medication) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.delete,
            style: const TextStyle(fontFamily: 'Cairo')),
        content: Text(
          AppStrings.deleteMedicationQuestion(medication.name),
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel,
                style: const TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<MedicationCubit>().deleteMedication(medication.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(AppStrings.delete,
                style: const TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}

// Empty View
class _EmptyView extends StatelessWidget {
  final bool isSearching;

  const _EmptyView({required this.isSearching});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSearching
                  ? Icons.search_off_rounded
                  : Icons.medication_outlined,
              size: 52,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isSearching ? AppStrings.noResults : AppStrings.noMedications,
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? AppStrings.tryAnotherSearch
                : AppStrings.addFirstMedication,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// Medication Card with Visual Drug Box & Color Swatch
class _MedicationCard extends StatelessWidget {
  final MedicationEntity medication;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _MedicationCard({
    required this.medication,
    required this.onDelete,
    required this.onEdit,
  });

  Color _getBoxColor() {
    if (medication.boxColorHex != null && medication.boxColorHex!.isNotEmpty) {
      try {
        return Color(int.parse('0xFF${medication.boxColorHex}'));
      } catch (_) {}
    }
    return AppColors.primary;
  }

  IconData _getFormIcon() {
    switch (medication.form) {
      case MedicationForm.syrup:
        return Icons.local_drink_outlined;
      case MedicationForm.injection:
        return Icons.vaccines_outlined;
      case MedicationForm.capsule:
        return Icons.medication_outlined;
      case MedicationForm.drops:
        return Icons.water_drop_outlined;
      case MedicationForm.cream:
        return Icons.sanitizer_outlined;
      default:
        return Icons.medication_rounded;
    }
  }

  String _getFormName() {
    switch (medication.form) {
      case MedicationForm.syrup:
        return 'شراب';
      case MedicationForm.injection:
        return 'حقنة';
      case MedicationForm.capsule:
        return 'كبسولة';
      case MedicationForm.drops:
        return 'قطرة';
      case MedicationForm.cream:
        return 'كريم';
      default:
        return 'قرص';
    }
  }

  @override
  Widget build(BuildContext context) {
    final boxColor = _getBoxColor();
    final hasPhoto =
        medication.boxImageUrl != null && medication.boxImageUrl!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: boxColor.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Drug Box Thumbnail or Color Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: boxColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: boxColor, width: 2),
              ),
              child: hasPhoto
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: medication.boxImageUrl!.startsWith('http')
                          ? Image.network(medication.boxImageUrl!,
                              fit: BoxFit.cover)
                          : Image.file(File(medication.boxImageUrl!),
                              fit: BoxFit.cover),
                    )
                  : Icon(_getFormIcon(), color: boxColor, size: 30),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: boxColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          medication.nameAr.isNotEmpty
                              ? '${medication.nameAr} (${medication.name})'
                              : medication.name,
                          style: AppTextStyles.label,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${medication.dosage} ${medication.unit} — ${_getFormName()}',
                    style: AppTextStyles.bodySmall,
                  ),
                  if (medication.schedules.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          medication.schedules.first.times.join(' — '),
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Actions
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: AppColors.primary, size: 20),
                  onPressed: onEdit,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
                const SizedBox(height: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.error, size: 20),
                  onPressed: onDelete,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
