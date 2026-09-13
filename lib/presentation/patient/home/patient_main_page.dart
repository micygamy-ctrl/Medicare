import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../domain/repositories/i_intake_log_repository.dart';
import '../../../domain/repositories/i_lab_report_repository.dart';
import '../../../domain/repositories/i_medication_repository.dart';
import '../../../domain/repositories/i_pairing_repository.dart';
import '../../../domain/repositories/i_vitals_repository.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../lab_reports/cubit/lab_report_cubit.dart';
import '../medications/cubit/medication_cubit.dart';
import '../pairing/cubit/pairing_cubit.dart';
import '../reminders/cubit/reminder_cubit.dart';
import '../vitals/cubit/vitals_cubit.dart';
import 'patient_home_page.dart';

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
              BlocProvider(
                create: (_) => MedicationCubit(getIt<IMedicationRepository>()),
              ),
              BlocProvider(
                create: (_) => ReminderCubit(
                  intakeLogRepository: getIt<IIntakeLogRepository>(),
                  medicationRepository: getIt<IMedicationRepository>(),
                ),
              ),
              BlocProvider(
                create: (_) => PairingCubit(getIt<IPairingRepository>()),
              ),
              BlocProvider(
                create: (_) => LabReportCubit(getIt<ILabReportRepository>()),
              ),
              BlocProvider(
                create: (_) => VitalsCubit(getIt<IVitalsRepository>()),
              ),
            ],
            child: const PatientHomePage(),
          ),
        );
      },
    );
  }
}
