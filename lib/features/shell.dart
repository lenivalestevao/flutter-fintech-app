import 'package:flutter/material.dart';

import 'activity/activity_screen.dart';
import 'cards/cards_screen.dart';
import 'home/home_screen.dart';
import 'insights/insights_screen.dart';

typedef _Destination = ({String label, IconData icon, IconData selected});

/// Adaptive navigation: bottom bar on phones, side rail on tablets/desktop.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const List<_Destination> _items = [
    (label: 'Home', icon: Icons.home_outlined, selected: Icons.home_rounded),
    (
      label: 'Activity',
      icon: Icons.receipt_long_outlined,
      selected: Icons.receipt_long_rounded
    ),
    (
      label: 'Cards',
      icon: Icons.credit_card_outlined,
      selected: Icons.credit_card_rounded
    ),
    (
      label: 'Insights',
      icon: Icons.donut_large_outlined,
      selected: Icons.donut_large_rounded
    ),
  ];

  int _index = 0;

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final body = IndexedStack(
      index: _index,
      children: [
        HomeScreen(onSeeAll: () => _go(1)),
        const ActivityScreen(),
        const CardsScreen(),
        const InsightsScreen(),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 840) {
          return Scaffold(
            body: body,
            bottomNavigationBar: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _go,
              destinations: [
                for (final item in _items)
                  NavigationDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selected),
                    label: item.label,
                  ),
              ],
            ),
          );
        }
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: _index,
                onDestinationSelected: _go,
                labelType: NavigationRailLabelType.all,
                destinations: [
                  for (final item in _items)
                    NavigationRailDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selected),
                      label: Text(item.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: body),
            ],
          ),
        );
      },
    );
  }
}
