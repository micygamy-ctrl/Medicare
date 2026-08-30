import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/i_intake_log_repository.dart';
import '../../../domain/repositories/i_medication_repository.dart';
import '../../../domain/repositories/i_pairing_repository.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../home/patient_home_page.dart';
import '../medications/cubit/medication_cubit.dart';
import '../medications/pages/medication_list_page.dart';
import '../pairing/cubit/pairing_cubit.dart';
import '../reminders/cubit/reminder_cubit.dart';
import '../reminders/pages/adherence_page.dart';
import '../reminders/pages/today_reminders_page.dart';
import '../profile/pages/patient_profile_page.dart';
import '../../../core/utils/connectivity_service.dart';

class PatientMainPage extends StatelessWidget {
  const PatientMainPage({super.key});

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

        return BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
          child: MultiBlocProvider(
            providers: [
              // Feature-scoped Cubits — بيتعمل بس لما المستخدم Patient
              BlocProvider(
                create: (_) => MedicationCubit(
                  getIt<IMedicationRepository>(),
                ),
              ),
              BlocProvider(
                create: (_) => ReminderCubit(
                  intakeLogRepository: getIt<IIntakeLogRepository>(),
                  medicationRepository: getIt<IMedicationRepository>(),
                ),
              ),
              BlocProvider(
                create: (_) => PairingCubit(
                  getIt<IPairingRepository>(),
                ),
              ),
            ],
            child: _PatientScaffold(user: user),
          ),
        );
      },
    );
  }
}

class _PatientScaffold extends StatefulWidget {
  final UserEntity user;

  const _PatientScaffold({required this.user});

  @override
  State<_PatientScaffold> createState() => _PatientScaffoldState();
}

class _PatientScaffoldState extends State<_PatientScaffold> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const PatientHomePage(),
      TodayRemindersPage(patientId: widget.user.uid),
      MedicationListPage(patientId: widget.user.uid),
      AdherencePage(patientId: widget.user.uid),
      PatientProfilePage(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          // Connectivity Banner
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _ConnectivityBannerWidget(),
          ),
        ],
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
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications_active_rounded),
              label: 'التذكيرات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medication_outlined),
              activeIcon: Icon(Icons.medication_rounded),
              label: 'أدويتي',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: 'إحصائيات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'ملفي',
            ),
          ],
        ),
      ),
    );
  }
}

// Connectivity Banner Widget
class _ConnectivityBannerWidget extends StatefulWidget {
  const _ConnectivityBannerWidget();

  @override
  State<_ConnectivityBannerWidget> createState() =>
      _ConnectivityBannerWidgetState();
}

class _ConnectivityBannerWidgetState
    extends State<_ConnectivityBannerWidget>
    with SingleTickerProviderStateMixin {
  final ConnectivityService _connectivityService = ConnectivityService();
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isConnected = true;
  bool _show = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _isConnected = _connectivityService.isConnected;

    _connectivityService.connectionStream.listen((isConnected) {
      if (!mounted) return;
      setState(() {
        _isConnected = isConnected;
        _show = true;
      });
      _controller.forward();

      if (isConnected) {
        Future.delayed(const Duration(seconds: 3), () {
          if (!mounted) return;
          _controller.reverse().then((_) {
            if (mounted) setState(() => _show = false);
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_show) return const SizedBox.shrink();

    return SizeTransition(
      sizeFactor: _animation,
      child: Container(
        width: double.infinity,
        color: _isConnected ? AppColors.success : AppColors.error,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isConnected ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _isConnected
                    ? 'تم استعادة الاتصال ✓'
                    : 'لا يوجد اتصال بالإنترنت',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}