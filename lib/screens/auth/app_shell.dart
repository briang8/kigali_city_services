import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/home_screen.dart';
import '../bookmarks/bookmarks_screen.dart';
import '../map/map_screen.dart';
import '../my_listings/my_listings_screen.dart';
import '../settings/settings_screen.dart';
import '../../constants/app_theme.dart';

// Active tab index — exposed so any screen can switch tabs programmatically
final activeTabProvider = NotifierProvider<_TabNotifier, int>(_TabNotifier.new);

class _TabNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void go(int i) => state = i;
}

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  // Use a getter so each screen instance is created fresh per build,
  // which prevents MapController from being initialised before its
  // FlutterMap widget is mounted in the IndexedStack.
  List<Widget> get _screens => const [
        HomeScreen(),
        BookmarksScreen(),
        MapScreen(),
        MyListingsScreen(),
        SettingsScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    final idx = ref.watch(activeTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: idx,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: idx,
          onTap: (i) => ref.read(activeTabProvider.notifier).go(i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_border_outlined),
              activeIcon: Icon(Icons.bookmark),
              label: 'Bookmarks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Map View',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined),
              activeIcon: Icon(Icons.list_alt),
              label: 'My Listings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
