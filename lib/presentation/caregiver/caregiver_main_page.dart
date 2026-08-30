import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/cubit/auth_cubit.dart';
import 'dashboard/caregiver_dashboard_page.dart';
import 'pairing/pages/enter_pair_code_page.dart';
import 'profile/caregiver_profile_page.dart';

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
                onTap: (index) =>
                    setState(() => _currentIndex = index),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard_outlined),
                    activeIcon: Icon(Icons.dashboard_rounded),
                    label: 'لوحة المتابعة',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_add_outlined),
                    activeIcon: Icon(Icons.person_add_rounded),
                    label: 'ربط مريض',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline_rounded),
                    activeIcon: Icon(Icons.person_rounded),
                    label: 'حسابي',
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