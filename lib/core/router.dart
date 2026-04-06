import 'package:go_router/go_router.dart';

import '../features/quran/presentation/screens/quran_menu_screen.dart';
import '../features/quran/presentation/screens/quran_reader_screen.dart';
import '../features/quran/presentation/screens/splash_screen.dart';
import '../features/quran/presentation/screens/main_screen.dart';
import '../features/quran/presentation/screens/home_screen.dart';
import '../features/quran/presentation/screens/bookmarks_screen.dart';
import '../features/hadith/presentation/screens/hadith_picker_screen.dart';
import '../features/hadith/presentation/screens/hadith_chapters_screen.dart';
import '../features/hadith/presentation/screens/hadith_reader_screen.dart';
import 'constants/app_constants.dart';

// Top-level router instance used by MaterialApp.router
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    ShellRoute(
      builder: (context, state, child) => MainScreen(child: child),
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/quran',
          builder: (context, state) => const QuranMenuScreen(),
          routes: [
            GoRoute(
              path: 'reader',
              builder: (context, state) {
                final pageParam = state.uri.queryParameters['page'];
                final page = int.tryParse(pageParam ?? '') ?? 1;
                final clamped = page.clamp(1, AppConstants.totalPages);
                return QuranReaderScreen(initialPage: clamped);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/hadith',
          builder: (context, state) => const HadithPickerScreen(),
          routes: [
            GoRoute(
              path: ':bookKey',
              builder: (context, state) {
                final bookKey = state.pathParameters['bookKey']!;
                return HadithChaptersScreen(bookKey: bookKey);
              },
              routes: [
                GoRoute(
                  path: ':chapterNumber',
                  builder: (context, state) {
                    final bookKey = state.pathParameters['bookKey']!;
                    final chapterNumber = int.parse(
                      state.pathParameters['chapterNumber']!,
                    );
                    return HadithReaderScreen(
                      bookKey: bookKey,
                      chapterNumber: chapterNumber,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/bookmarks',
          builder: (context, state) => const BookmarksScreen(),
        ),
      ],
    ),
  ],
);
