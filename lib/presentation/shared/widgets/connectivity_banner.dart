import 'package:flutter/material.dart';
import '../../../core/utils/connectivity_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ConnectivityBanner extends StatefulWidget {
  final Widget child;

  const ConnectivityBanner({super.key, required this.child});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  final ConnectivityService _connectivityService = ConnectivityService();
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isConnected = true;
  bool _showBanner = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _isConnected = _connectivityService.isConnected;

    _connectivityService.connectionStream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
          _showBanner = true;
        });

        if (isConnected) {
          _animationController.forward();
          // إخفاء الـ banner بعد 3 ثواني لو النت رجع
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              _animationController.reverse().then((_) {
                if (mounted) setState(() => _showBanner = false);
              });
            }
          });
        } else {
          _animationController.forward();
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Connectivity Banner
        if (_showBanner)
          SizeTransition(
            sizeFactor: _animation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              color: _isConnected
                  ? AppColors.success
                  : AppColors.error,
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isConnected
                          ? Icons.wifi_rounded
                          : Icons.wifi_off_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isConnected
                          ? 'تم استعادة الاتصال بالإنترنت'
                          : 'لا يوجد اتصال بالإنترنت',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Main Content
        Expanded(child: widget.child),
      ],
    );
  }
}