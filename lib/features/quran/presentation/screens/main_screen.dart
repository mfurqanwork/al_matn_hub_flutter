import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatefulWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/quran')) {
      return 1;
    }
    if (location.startsWith('/hadith')) {
      return 2;
    }
    if (location.startsWith('/bookmarks')) {
      return 3;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/quran');
        break;
      case 2:
        context.go('/hadith');
        break;
      case 3:
        context.go('/bookmarks');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        selectedItemColor: const Color(0xFF007A33),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Opacity(
              opacity: _calculateSelectedIndex(context) == 0 ? 1.0 : 0.4,
              child: Image.asset(
                'assets/icons/ic_home.png',
                width: 28,
                height: 28,
              ),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Opacity(
              opacity: _calculateSelectedIndex(context) == 1 ? 1.0 : 0.4,
              child: Image.asset(
                'assets/icons/ic_quran.png',
                width: 28,
                height: 28,
              ),
            ),
            label: 'Quran',
          ),
          BottomNavigationBarItem(
            icon: Opacity(
              opacity: _calculateSelectedIndex(context) == 2 ? 1.0 : 0.4,
              child: Image.asset(
                'assets/icons/ic_quran.png', // Same icon as quran
                width: 28,
                height: 28,
              ),
            ),
            label: 'Hadith',
          ),
          BottomNavigationBarItem(
            icon: Opacity(
              opacity: _calculateSelectedIndex(context) == 3 ? 1.0 : 0.4,
              child: Image.asset(
                'assets/icons/ic_bookmark.png',
                width: 28,
                height: 28,
              ),
            ),
            label: 'Bookmarks',
          ),
        ],
      ),
    );
  }
}
