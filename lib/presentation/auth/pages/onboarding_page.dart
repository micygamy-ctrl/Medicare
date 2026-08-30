import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../shared/widgets/primary_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.medication_rounded,
      color: AppColors.primary,
      title: 'إدارة أدويتك بسهولة',
      subtitle:
          'أضف أدويتك ومواعيدها وتلقّ تذكيرات يومية\nلا تفوّت أي جرعة مهمة',
    ),
    _OnboardingData(
      icon: Icons.notifications_active_rounded,
      color: AppColors.secondary,
      title: 'تذكيرات ذكية',
      subtitle:
          'نُذكّرك بموعد كل دواء في وقته\nوسجّل ما أخذته وما فاتك بضغطة واحدة',
    ),
    _OnboardingData(
      icon: Icons.favorite_rounded,
      color: AppColors.error,
      title: 'متابعة من أهلك',
      subtitle:
          'اربط حسابك مع أحد أفراد العائلة\nليتابع صحتك ويطمئن عليك دائماً',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topLeft,
              child: TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
                child: Text(
                  'تخطي',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) =>
                    setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: page.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page.icon,
                            size: 72,
                            color: page.color,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Title
                        Text(
                          page.title,
                          style: AppTextStyles.h1.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Subtitle
                        Text(
                          page.subtitle,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.7,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? AppColors.primary
                        : AppColors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: PrimaryButton(
                label: _currentPage == _pages.length - 1
                    ? 'ابدأ الآن'
                    : 'التالي',
                onPressed: _next,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _OnboardingData({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
}