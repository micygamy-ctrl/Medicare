import 'package:flutter/material.dart';
import '../../../core/constants/app_routes.dart';

class UnknownRoutePage extends StatelessWidget {
  final String? routeName;

  const UnknownRoutePage({super.key, this.routeName});

  @override
  Widget build(BuildContext context) {
    final routeLabel = routeName == null || routeName!.isEmpty
        ? 'المسار المطلوب'
        : routeName!;

    return Scaffold(
      appBar: AppBar(title: const Text('الصفحة غير موجودة')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              const Text(
                'عذرًا، الصفحة التي طلبتها غير موجودة.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                routeLabel,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.splash,
                      (_) => false,
                    ),
                child: const Text('العودة للرئيسية'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}