import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/localization/app_strings.dart';
import '../auth/cubit/auth_cubit.dart';
import 'dashboard/caregiver_dashboard_page.dart';
import 'pairing/pages/enter_pair_code_page.dart';
import 'profile/caregiver_profile_page.dart';
import '../shared/widgets/app_drawer.dart';

class CaregiverMainPage extends StatefulWidget {
  const CaregiverMainPage({super.key});

  @override
  State<CaregiverMainPage> createState() => _CaregiverMainPageState();
}

class _CaregiverMainPageState extends State<CaregiverMainPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;

        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final pages = [
          const CaregiverDashboardPage(),
          EnterPairCodePage(
            caregiverId: user.uid,
            caregiverName: user.displayName,
          ),
          CaregiverProfilePage(user: user),
        ];

        return BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
          child: Scaffold(
            drawer: AppDrawer(
              user: user,
              selectedIndex: _currentIndex,
              onSelectMainItem: (index) => setState(() => _currentIndex = index),
            ),
            body: IndexedStack(
              index: _currentIndex,
              children: pages,
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.dashboard_outlined),
                    activeIcon: const Icon(Icons.dashboard_rounded),
                    label: AppStrings.menuDashboard,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.person_add_outlined),
                    activeIcon: const Icon(Icons.person_add_rounded),
                    label: AppStrings.tabPairPatient,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.person_outline_rounded),
                    activeIcon: const Icon(Icons.person_rounded),
                    label: AppStrings.tabProfile,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
