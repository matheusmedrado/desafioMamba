import 'package:flutter/material.dart';

import '../features/fasting/presentation/fasting_home_screen.dart';
import '../features/meals/presentation/meals_screen.dart';
import 'theme.dart';

/// Signed-in screens behind the bottom navigation.
///
/// A tab is built the first time it is opened and then kept, so switching tabs
/// does not reload it and the meals database opens only when Meals is used.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _mealsTab = 1;

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
          const FastingHomeScreen(),
          if (_opened.contains(_mealsTab))
            const MealsScreen()
          else
            const SizedBox.shrink(),
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
          ],
        ),
      ),
    );
  }
}
