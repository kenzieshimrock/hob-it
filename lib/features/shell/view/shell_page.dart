import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hob_it/features/discovery/bloc/discovery_bloc.dart';
import 'package:hob_it/features/discovery/view/discovery_page.dart';
import 'package:hob_it/features/hobbies/hobbies.dart';
import 'package:hob_it/features/home/view/home_page.dart';
import 'package:hob_it/features/settings/settings.dart';
import 'package:hob_it/features/shell/cubit/shell_tab_cubit.dart';
import 'package:hob_it/genui/hobby_conversation.dart';
import 'package:hob_it/ui/ui.dart';
import 'package:hobby_repository/hobby_repository.dart';

/// Root shell that owns the bottom navigation bar.
///
/// Provides the shell-scoped [ShellTabCubit] and the shared [DiscoveryBloc]
/// (so any tab can open and drive Discover), then renders the tabbed
/// scaffold via [_ShellView].
class ShellPage extends StatelessWidget {
  /// Creates a [ShellPage].
  const ShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ShellTabCubit()),
        BlocProvider(
          create: (context) => DiscoveryBloc(
            conversationFactory: HobbyConversation.new,
            hobbyRepository: context.read<HobbyRepository>(),
          ),
        ),
      ],
      child: const _ShellView(),
    );
  }
}

/// The visual layer of the shell: an app bar, an [IndexedStack] of tab pages,
/// and a bottom [NavigationBar] driven by [ShellTabCubit].
class _ShellView extends StatelessWidget {
  const _ShellView();

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
    return BlocBuilder<ShellTabCubit, ShellTab>(
      builder: (context, tab) {
        final index = tab.index;
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
                  _tabs[index].tagLabel,
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
          body: IndexedStack(index: index, children: _pages),
          bottomNavigationBar: NavigationBar(
            backgroundColor: HobItColors.scaffold,
            indicatorColor: HobItColors.blue20,
            selectedIndex: index,
            onDestinationSelected: (i) =>
                context.read<ShellTabCubit>().select(ShellTab.values[i]),
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

  /// Display label shown in the bottom bar.
  final String label;

  /// Icon shown when the tab is inactive.
  final IconData icon;

  /// Icon shown when the tab is active.
  final IconData activeIcon;

  /// Amber uppercase tag shown in the app bar when this tab is active.
  final String tagLabel;
}
