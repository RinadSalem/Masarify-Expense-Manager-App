 

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
     
    Future.delayed(const Duration(milliseconds: 2500), () {
      Get.offAllNamed('/auth');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [Color(0xFF1C1B29), AppTheme.bgColor],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppTheme.gradientPrimary,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 28),

               
              Text(
                'مصاريفي',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 40,
                      letterSpacing: 2,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: AppTheme.gradientPrimary,
                        ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                    ),
              )
                  .animate(delay: 300.ms)
                  .slideY(begin: 0.3, duration: 500.ms, curve: Curves.easeOut)
                  .fadeIn(),

              const SizedBox(height: 12),

              Text(
                'تتبع مصاريفك بذكاء',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
              ).animate(delay: 500.ms).fadeIn(duration: 500.ms),

              const SizedBox(height: 60),

               
              SizedBox(
                width: 40,
                height: 4,
                child: LinearProgressIndicator(
                  backgroundColor: AppTheme.surfaceColor,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ).animate(delay: 700.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}
