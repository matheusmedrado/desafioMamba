import 'package:flutter/material.dart';

import '../features/fasting/presentation/fasting_home_screen.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/meals/presentation/meals_screen.dart';
import 'theme.dart';

/// Signed-in tabs. Each tab is built on first open and then kept.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _screens = <Widget>[
    FastingHomeScreen(),
    MealsScreen(),
    HistoryScreen(),
  ];

  var _index = 0;
  final _opened = <int>{0};

  void _select(int index) {
    setState(() {
      _index = index;
      _opened.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          for (final (index, screen) in _screens.indexed)
            _opened.contains(index) ? screen : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: MambaColors.border)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _select,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.timer_outlined),
              selectedIcon: Icon(Icons.timer),
              label: 'Today',
            ),
            NavigationDestination(
              icon: Icon(Icons.restaurant_outlined),
              selectedIcon: Icon(Icons.restaurant),
              label: 'Meals',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}
