import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/localization/app_language_cubit.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/i_lab_report_repository.dart';
import '../../../domain/repositories/i_pairing_repository.dart';
import '../../../domain/repositories/i_vitals_repository.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../patient/lab_reports/cubit/lab_report_cubit.dart';
import '../../patient/lab_reports/pages/health_recommendations_page.dart';
import '../../patient/lab_reports/pages/lab_reports_list_page.dart';
import '../../patient/pairing/cubit/pairing_cubit.dart';
import '../../patient/pairing/pages/pair_code_page.dart';
import '../../patient/reminders/pages/adherence_page.dart';
import '../../patient/vitals/cubit/vitals_cubit.dart';
import '../../patient/vitals/pages/vitals_dashboard_page.dart';

class AppDrawer extends StatelessWidget {
  final UserEntity? user;
  final int? selectedIndex;
  final ValueChanged<int>? onSelectMainItem;
  final VoidCallback? onLinkPatient;
  final VoidCallback? onDoctorPair;

  const AppDrawer({
    super.key,
    required this.user,
    this.selectedIndex,
    this.onSelectMainItem,
    this.onLinkPatient,
    this.onDoctorPair,
  });

  String _getRoleTitle(UserRole? role) {
    switch (role) {
      case UserRole.patient:
        return AppStrings.rolePatient;
      case UserRole.caregiver:
        return AppStrings.roleCaregiver;
      case UserRole.doctor:
        return AppStrings.roleDoctor;
      default:
        return AppStrings.rolePatient;
    }
  }

  void _select(BuildContext context, int index) {
    Navigator.pop(context);
    onSelectMainItem?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLanguageCubit, AppLanguageState>(
      builder: (context, langState) {
        return Drawer(
          backgroundColor: AppColors.surface,
          child: SafeArea(
            child: Column(
              children: [
                _DrawerHeader(user: user, roleTitle: _getRoleTitle(user?.role)),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    children: [
                      _SectionLabel(AppStrings.menuTitle),
                      ..._mainItems(context),
                      if (user?.role == UserRole.patient) ...[
                        const SizedBox(height: 12),
                        _SectionLabel(AppStrings.menuServices),
                        ..._patientServiceItems(context),
                      ],
                      const SizedBox(height: 12),
                      _LanguageTile(langState: langState),
                    ],
                  ),
                ),
                const Divider(height: 1),
                _DrawerItem(
                  icon: Icons.logout_rounded,
                  iconColor: AppColors.error,
                  title: AppStrings.menuLogout,
                  subtitle: '',
                  compact: true,
                  onTap: () {
                    Navigator.pop(context);
                    context.read<AuthCubit>().signOut();
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _mainItems(BuildContext context) {
    switch (user?.role) {
      case UserRole.caregiver:
        return [
          _DrawerItem(
            icon: Icons.dashboard_rounded,
            iconColor: AppColors.primary,
            title: AppStrings.menuDashboard,
            subtitle: AppStrings.caregiverDashboard,
            selected: selectedIndex == 0,
            onTap: () => _select(context, 0),
          ),
          _DrawerItem(
            icon: Icons.person_add_alt_1_rounded,
            iconColor: AppColors.secondary,
            title: AppStrings.tabPairPatient,
            subtitle: AppStrings.menuPairingSub,
            selected: selectedIndex == 1,
            onTap: onLinkPatient == null
                ? () => _select(context, 1)
                : () {
                    Navigator.pop(context);
                    onLinkPatient?.call();
                  },
          ),
          _DrawerItem(
            icon: Icons.person_rounded,
            iconColor: AppColors.warning,
            title: AppStrings.tabProfile,
            subtitle: AppStrings.currentLanguage,
            selected: selectedIndex == 2,
            onTap: () => _select(context, 2),
          ),
        ];
      case UserRole.doctor:
        return [
          _DrawerItem(
            icon: Icons.dashboard_rounded,
            iconColor: AppColors.primary,
            title: AppStrings.menuDoctorDashboard,
            subtitle: AppStrings.linkedPatients,
            selected: selectedIndex == 0,
            onTap: () => _select(context, 0),
          ),
          _DrawerItem(
            icon: Icons.person_add_alt_1_rounded,
            iconColor: AppColors.secondary,
            title: AppStrings.tabDoctorPairing,
            subtitle: AppStrings.menuPairingSub,
            onTap: () {
              Navigator.pop(context);
              onDoctorPair?.call();
            },
          ),
          _DrawerItem(
            icon: Icons.person_rounded,
            iconColor: AppColors.warning,
            title: AppStrings.tabProfile,
            subtitle: AppStrings.doctorProfileTitle,
            selected: selectedIndex == 1,
            onTap: () => _select(context, 1),
          ),
        ];
      case UserRole.patient:
      default:
        return [
          _DrawerItem(
            icon: Icons.home_rounded,
            iconColor: AppColors.primary,
            title: AppStrings.tabHome,
            subtitle: AppStrings.welcomeSubtitle,
            selected: selectedIndex == 0,
            onTap: () => _select(context, 0),
          ),
          _DrawerItem(
            icon: Icons.notifications_active_rounded,
            iconColor: AppColors.warning,
            title: AppStrings.tabReminders,
            subtitle: AppStrings.nextDose,
            selected: selectedIndex == 1,
            onTap: () => _select(context, 1),
          ),
          _DrawerItem(
            icon: Icons.medication_rounded,
            iconColor: AppColors.secondary,
            title: AppStrings.tabMedications,
            subtitle: AppStrings.addMedication,
            selected: selectedIndex == 2,
            onTap: () => _select(context, 2),
          ),
          _DrawerItem(
            icon: Icons.person_rounded,
            iconColor: AppColors.success,
            title: AppStrings.tabProfile,
            subtitle: AppStrings.rolePatient,
            selected: selectedIndex == 3,
            onTap: () => _select(context, 3),
          ),
        ];
    }
  }

  List<Widget> _patientServiceItems(BuildContext context) {
    if (user == null) return const [];

    return [
      _DrawerItem(
        icon: Icons.document_scanner_rounded,
        iconColor: AppColors.primary,
        title: AppStrings.menuLabReports,
        subtitle: AppStrings.menuLabReportsSub,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => LabReportCubit(getIt<ILabReportRepository>()),
                child: LabReportsListPage(
                  patientId: user!.uid,
                  chronicConditions: user!.chronicDiseases,
                ),
              ),
            ),
          );
        },
      ),
      _DrawerItem(
        icon: Icons.restaurant_rounded,
        iconColor: AppColors.success,
        title: AppStrings.menuRecommendations,
        subtitle: AppStrings.menuRecommendationsSub,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => LabReportCubit(getIt<ILabReportRepository>()),
                child: HealthRecommendationsPage(
                  patientId: user!.uid,
                  chronicConditions: user!.chronicDiseases,
                ),
              ),
            ),
          );
        },
      ),
      _DrawerItem(
        icon: Icons.monitor_heart_rounded,
        iconColor: AppColors.warning,
        title: AppStrings.menuVitals,
        subtitle: AppStrings.menuVitalsSub,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => VitalsCubit(getIt<IVitalsRepository>()),
                child: VitalsDashboardPage(patientId: user!.uid),
              ),
            ),
          );
        },
      ),
      _DrawerItem(
        icon: Icons.bar_chart_rounded,
        iconColor: AppColors.secondary,
        title: AppStrings.menuAnalytics,
        subtitle: AppStrings.menuAnalyticsSub,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdherencePage(patientId: user!.uid),
            ),
          );
        },
      ),
      _DrawerItem(
        icon: Icons.link_rounded,
        iconColor: AppColors.error,
        title: AppStrings.menuPairing,
        subtitle: AppStrings.menuPairingSub,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => PairingCubit(getIt<IPairingRepository>()),
                child: PairCodePage(
                  patientId: user!.uid,
                  patientName: user!.displayName,
                ),
              ),
            ),
          );
        },
      ),
    ];
  }
}

class _DrawerHeader extends StatelessWidget {
  final UserEntity? user;
  final String roleTitle;

  const _DrawerHeader({required this.user, required this.roleTitle});

  @override
  Widget build(BuildContext context) {
    final name = user?.displayName.isNotEmpty == true
        ? user!.displayName
        : AppStrings.genericUser;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'M';

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    roleTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
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

class _LanguageTile extends StatelessWidget {
  final AppLanguageState langState;

  const _LanguageTile({required this.langState});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: SwitchListTile(
        secondary:
            const Icon(Icons.language_rounded, color: AppColors.secondary),
        title: Text(
          AppStrings.menuLanguage,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        subtitle: Text(AppStrings.currentLanguage),
        value: !langState.isArabic,
        activeColor: AppColors.secondary,
        onChanged: (_) => context.read<AppLanguageCubit>().toggleLanguage(),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 6),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool selected;
  final bool compact;

  const _DrawerItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.selected = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: selected ? iconColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border:
            selected ? Border.all(color: iconColor.withOpacity(0.28)) : null,
      ),
      child: ListTile(
        dense: compact,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 21),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
            fontSize: 14,
            color: selected ? iconColor : AppColors.textPrimary,
          ),
        ),
        subtitle: subtitle.isEmpty
            ? null
            : Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary),
              ),
        onTap: onTap,
      ),
    );
  }
}
