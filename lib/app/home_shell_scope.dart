import 'package:flutter/widgets.dart';

/// Lets screens inside the tab shell switch tabs.
class HomeShellScope extends InheritedWidget {
  const HomeShellScope({
    super.key,
    required this.selectTab,
    required super.child,
  });

  static const todayTab = 0;
  static const mealsTab = 1;
  static const historyTab = 2;

  final ValueChanged<int> selectTab;

  static HomeShellScope? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<HomeShellScope>();

  @override
  bool updateShouldNotify(HomeShellScope oldWidget) => false;
}
