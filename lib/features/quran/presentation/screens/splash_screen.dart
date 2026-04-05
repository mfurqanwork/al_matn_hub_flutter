import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Artificial delay for splash screen visibility
    await Future.delayed(const Duration(seconds: 2));

    int page = 1;
    try {
      final prefs = await SharedPreferences.getInstance();
      page = prefs.getInt(AppConstants.prefLastReadPage) ?? 1;
    } on MissingPluginException {
      page = 1;
    }

    if (mounted) {
      // For now, let's go to Quran reader as requested by previous logic,
      // but we could also go to a new Home screen.
      context.go('/quran/reader?page=$page');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background pattern
          SvgPicture.asset(
            'assets/icons/splash_bg.svg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Logo and animation
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'app_logo',
                  child: Image.asset(
                    'assets/icons/logo.png',
                    width: 150,
                    height: 150,
                  ),
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007A33)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
