import 'package:flutter/material.dart';
import 'package:hob_it/ui/ui.dart';

/// The Home tab — memory-driven feed of generated hobby surfaces.
///
/// On first use (no stored memory), shows a prompt to start a discovery.
/// Once memory exists, the agent generates [RecommendedHobby],
/// [ProactiveNudge], and [ProgressPath] widgets from Firestore.
///
/// GenUI [Conversation] wiring is added in a future step.
class HomePage extends StatelessWidget {
  /// Creates a [HomePage].
  const HomePage({super.key});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'GOOD MORNING';
    if (hour < 17) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: HobItSpacing.lg,
        vertical: HobItSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_greeting, style: HobItTypography.agentLabel),
          const SizedBox(height: HobItSpacing.xs),
          Text(
            'Three things I lined up for you',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: HobItSpacing.lg),
          _StartSomethingNewTile(),
          // TODO: GenUI surfaces render here once Conversation is wired.
        ],
      ),
    );
  }
}

/// Quick-action tile that navigates the user to the Discover tab.
///
/// Displayed on the Home feed as the primary CTA for new users
/// and as a persistent entry point for returning users.
class _StartSomethingNewTile extends StatelessWidget {
  const _StartSomethingNewTile();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: HobItSpacing.md,
          vertical: HobItSpacing.sm,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: HobItColors.blue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.explore_rounded,
            color: HobItColors.white,
            size: 20,
          ),
        ),
        title: Text(
          'Start something new',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Text(
          'Describe any hobby — no search needed',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: const Icon(
          Icons.arrow_forward_rounded,
          color: HobItColors.navy40,
        ),
        onTap: () {
          // TODO: Switch to Discover tab via ShellPage state.
        },
      ),
    );
  }
}
