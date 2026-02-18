import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/quran/presentation/screens/quran_menu_screen.dart';
import '../features/quran/presentation/screens/quran_reader_screen.dart';
import 'constants/app_constants.dart';

/// Returns the last-read page from SharedPreferences synchronously.
/// Falls back to page 1 if nothing is saved.
int _getLastReadPage(SharedPreferences prefs) {
  return prefs.getInt(AppConstants.prefLastReadPage) ?? 1;
}

// Top-level router instance used by MaterialApp.router
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const _HomeRedirectScreen(),
    ),
    GoRoute(
      path: '/quran',
      builder: (context, state) => const QuranMenuScreen(),
    ),
    GoRoute(
      path: '/quran/reader',
      builder: (context, state) {
        final pageParam = state.uri.queryParameters['page'];
        final page = int.tryParse(pageParam ?? '') ?? 1;
        final clamped = page.clamp(1, AppConstants.totalPages);
        return QuranReaderScreen(initialPage: clamped);
      },
    ),
  ],
);

/// Splash-style redirect: reads last-read page and jumps straight to the
/// Quran reader so the user's session is resumed on every launch.
class _HomeRedirectScreen extends StatefulWidget {
  const _HomeRedirectScreen();

  @override
  State<_HomeRedirectScreen> createState() => _HomeRedirectScreenState();
}

class _HomeRedirectScreenState extends State<_HomeRedirectScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    int page = 1;
    try {
      final prefs = await SharedPreferences.getInstance();
      page = _getLastReadPage(prefs);
    } on MissingPluginException {
      page = 1;
    }
    if (mounted) {
      context.go('/quran/reader?page=$page');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
