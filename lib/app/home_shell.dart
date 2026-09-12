import 'package:flutter/material.dart';

import '../features/fasting/presentation/fasting_home_screen.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/meals/presentation/meals_screen.dart';
import '../l10n/app_localizations.dart';
import 'home_shell_scope.dart';
import 'mamba_icon.dart';
import 'theme.dart';

List<String> _tabLabels(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return [l10n.today, l10n.mealsTab, l10n.historyTab];
}

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

  static const _icons = [
    MambaIcons.timer,
    MambaIcons.meals,
    MambaIcons.calendar,
  ];

  var _index = HomeShellScope.todayTab;
  final _opened = <int>{HomeShellScope.todayTab};

  void _select(int index) {
    setState(() {
      _index = index;
      _opened.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return HomeShellScope(
      selectTab: _select,
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            for (final (index, screen) in _screens.indexed)
              _opened.contains(index) ? screen : const SizedBox.shrink(),
          ],
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            color: MambaColors.background,
            border: Border(top: BorderSide(color: MambaColors.surfaceElevated)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 72,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Row(
                  children: [
                    for (final (index, icon) in _icons.indexed)
                      Expanded(
                        child: _NavItem(
                          icon: icon,
                          label: _tabLabels(context)[index],
                          selected: index == _index,
                          onTap: () => _select(index),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final MambaIcons icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? MambaColors.textPrimary
        : MambaColors.textSecondary;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (selected)
              Positioned(
                top: -4,
                child: Container(
                  width: 20,
                  height: 2,
                  color: MambaColors.purpleSoft,
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MambaIcon(
                  icon,
                  color: color,
                  strokeWidth: selected ? 2.4 : 1.8,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    height: 1,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
