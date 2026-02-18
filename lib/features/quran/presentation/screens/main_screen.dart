import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    if (location.startsWith('/bookmarks')) {
      return 2;
    }
    if (location.startsWith('/settings')) {
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
        context.go('/bookmarks');
        break;
      case 3:
        context.go('/settings');
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
            icon: SvgPicture.asset(
              'assets/icons/ic_home.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                _calculateSelectedIndex(context) == 0 ? const Color(0xFF007A33) : Colors.grey,
                BlendMode.srcIn,
              ),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/ic_quran.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                _calculateSelectedIndex(context) == 1 ? const Color(0xFF007A33) : Colors.grey,
                BlendMode.srcIn,
              ),
            ),
            label: 'Quran',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/ic_bookmark.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                _calculateSelectedIndex(context) == 2 ? const Color(0xFF007A33) : Colors.grey,
                BlendMode.srcIn,
              ),
            ),
            label: 'Bookmarks',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/ic_settings.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                _calculateSelectedIndex(context) == 3 ? const Color(0xFF007A33) : Colors.grey,
                BlendMode.srcIn,
              ),
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
