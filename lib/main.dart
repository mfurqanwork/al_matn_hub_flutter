import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/router.dart';
import 'features/hadith/data/models/hadith_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(HadithAdapter());
  
  runApp(const ProviderScope(child: AlMatnApp()));
}

class AlMatnApp extends StatelessWidget {
  const AlMatnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Al-Matn Hub',
      debugShowCheckedModeBanner: false,
      locale: const Locale('en'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007A33), // Emerald Green
          primary: const Color(0xFF007A33),
          secondary: const Color(0xFFB8860B), // Gold Accent
          surface: Colors.grey.shade50,
          onSurface: const Color(0xFF1A1A1A),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey.shade50,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white60, // white
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white60, // white
          selectedItemColor: Color(0xFFB8860B), // Gold
          unselectedItemColor: Colors.white60,
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007A33), // Emerald Green
          primary: const Color(0xFF007A33),
          secondary: const Color(0xFFB8860B), // Gold Accent
          surface: Colors.grey.shade50,
          onSurface: const Color(0xFF1A1A1A),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey.shade50,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white60, // white
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white60, // white
          selectedItemColor: Color(0xFFB8860B), // Gold
          unselectedItemColor: Colors.white60,
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
