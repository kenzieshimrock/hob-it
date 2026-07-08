import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hob_it/features/discovery/view/discovery_page.dart';
import 'package:hob_it/features/hobbies/hobbies.dart';
import 'package:hob_it/features/home/view/home_page.dart';
import 'package:hob_it/features/settings/settings.dart';
import 'package:hob_it/features/shell/cubit/shell_tab_cubit.dart';
import 'package:hob_it/ui/ui.dart';

/// Root shell that owns the bottom navigation bar.
///
/// Reads the selected tab from [ShellTabCubit] so other tabs can switch it.
class ShellPage extends StatelessWidget {
  /// Creates a [ShellPage].
  const ShellPage({super.key});

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
    return BlocBuilder<ShellTabCubit, int>(
      builder: (context, currentIndex) {
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
                  _tabs[currentIndex].tagLabel,
                  style: HobItTypography.agentLabel,
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(
                height: 1,
                thickness: 1,
                color: HobItColors.navy.withValues(alpha: 0.1),
              ),
            ),
          ),
          body: IndexedStack(index: currentIndex, children: _pages),
          bottomNavigationBar: NavigationBar(
            backgroundColor: HobItColors.scaffold,
            indicatorColor: HobItColors.blue20,
            selectedIndex: currentIndex,
            onDestinationSelected: (index) =>
                context.read<ShellTabCubit>().select(index),
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
      },
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

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String tagLabel;
}
