import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _loadingProgress = 0.0;
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize fonts - we now wait for 100% completion to ensure
    // maximum performance (60fps) and zero stuttering in the Mushaf.
    // Note: Debugging over wireless ADB can make this initial extraction slower.
    await QcfFontLoader.setupFontsAtStartup(
      onProgress: (double progress) {
        if (mounted) {
          setState(() {
            _loadingProgress = progress;
          });
        }
      },
    );
    
    // Brief extra delay for branding and smooth transition
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      // Go to the Home Dashboard first! This gives fonts time to load in the background
      context.go('/home');
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
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _loadingProgress,
                      minHeight: 6,
                      backgroundColor: const Color(0xFF007A33).withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF007A33)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
