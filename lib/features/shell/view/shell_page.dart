import 'package:flutter/material.dart';
import 'package:hob_it/features/discovery/view/discovery_page.dart';
import 'package:hob_it/features/hobbies/hobbies.dart';
import 'package:hob_it/features/home/view/home_page.dart';
import 'package:hob_it/features/settings/settings.dart';
import 'package:hob_it/ui/ui.dart';

/// Root shell that owns the bottom navigation bar.
///
/// Uses [IndexedStack] to preserve tab state across switches.
/// The shared app bar and bottom bar are defined here; individual
/// tab pages render only their body content.
class ShellPage extends StatefulWidget {
  /// Creates a [ShellPage].
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _currentIndex = 0;

  static const List<_TabItem> _tabs = [
    _TabItem(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      tagLabel: 'HOME',
    ),
    _TabItem(
      label: 'Discover',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
      tagLabel: 'DISCOVER',
    ),
    _TabItem(
      label: 'Hobbies',
      icon: Icons.layers_outlined,
      activeIcon: Icons.layers_rounded,
      tagLabel: 'HOBBIES',
    ),
    _TabItem(
      label: 'Settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      tagLabel: 'SETTINGS',
    ),
  ];

  static const List<Widget> _pages = [
    HomePage(),
    DiscoveryPage(),
    HobbiesPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HobItColors.scaffold,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: HobItColors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.explore_rounded,
                color: HobItColors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: HobItSpacing.sm),
            Text(
              'hob-it',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: HobItColors.navy),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: HobItSpacing.md),
            child: Text(
              _tabs[_currentIndex].tagLabel,
              style: HobItTypography.agentLabel,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: HobItColors.navy.withOpacity(0.1),
          ),
        ),
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        backgroundColor: HobItColors.scaffold,
        indicatorColor: HobItColors.blue20,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: _tabs
            .map(
              (tab) => NavigationDestination(
                icon: Icon(tab.icon, color: HobItColors.navy40),
                selectedIcon: Icon(tab.activeIcon, color: HobItColors.blue),
                label: tab.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

/// Metadata for a single bottom navigation tab.
class _TabItem {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.tagLabel,
  });

  /// Display label shown in the bottom bar.
  final String label;

  /// Icon shown when the tab is inactive.
  final IconData icon;

  /// Icon shown when the tab is active.
  final IconData activeIcon;

  /// Amber uppercase tag shown in the app bar when this tab is active.
  final String tagLabel;
}
