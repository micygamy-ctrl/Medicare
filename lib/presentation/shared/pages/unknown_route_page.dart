import 'package:flutter/material.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/localization/app_strings.dart';

class UnknownRoutePage extends StatelessWidget {
  final String? routeName;

  const UnknownRoutePage({super.key, this.routeName});

  @override
  Widget build(BuildContext context) {
    final routeLabel = routeName == null || routeName!.isEmpty
        ? ''
        : routeName!;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.pageNotFound)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              Text(
                AppStrings.pageNotFoundSubtitle,
                textAlign: TextAlign.center,
              ),
              if (routeLabel.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  routeLabel,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.splash,
                      (_) => false,
                    ),
                child: Text(AppStrings.backToHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}