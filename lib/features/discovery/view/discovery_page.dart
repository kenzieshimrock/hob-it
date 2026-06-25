import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hob_it/features/discovery/bloc/discovery_bloc.dart';
import 'package:hob_it/ui/ui.dart';

/// The Discover tab — entry point for starting a new hobby discovery.
///
/// Provides [DiscoveryBloc] to the widget subtree and delegates
/// rendering to [DiscoveryView].
class DiscoveryPage extends StatelessWidget {
  /// Creates a [DiscoveryPage].
  const DiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DiscoveryBloc(),
      child: const DiscoveryView(),
    );
  }
}

/// The visual layer of the Discover tab.
///
/// Shows an agent intro message, suggestion chips, and a pinned
/// chat-style input bar at the bottom of the screen.
class DiscoveryView extends StatelessWidget {
  /// Creates a [DiscoveryView].
  const DiscoveryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DiscoveryBloc, DiscoveryState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == DiscoveryStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Something went wrong. Try again.')),
          );
        }
      },
      child: const Column(
        children: [
          Expanded(child: _DiscoveryFeed()),
          _PinnedInputBar(),
        ],
      ),
    );
  }
}

/// Scrollable feed showing the agent intro and suggestion chips.
///
/// As the conversation progresses, GenUI surfaces render here
/// between the intro and the pinned input bar.
class _DiscoveryFeed extends StatelessWidget {
  const _DiscoveryFeed();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(HobItSpacing.lg),
      children: const [
        _AgentIntroMessage(),
        SizedBox(height: HobItSpacing.md),
        _SuggestionChips(),
      ],
    );
  }
}

/// Agent intro message bubble.
///
/// The dark navy bubble introduces hob-it and explains what it can do.
/// Styled to match the agent message pattern in the Flow C design.
class _AgentIntroMessage extends StatelessWidget {
  const _AgentIntroMessage();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: HobItColors.blue,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.explore_rounded,
            color: HobItColors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: HobItSpacing.sm),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(HobItSpacing.md),
            decoration: BoxDecoration(
              color: HobItColors.navy,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Text(
              "Hi, I'm hob-it. Tell me any hobby you'd like to try — "
              "I'll sort out the gear, admin, learning and community "
              "to get you started.",
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: HobItColors.white),
            ),
          ),
        ),
      ],
    );
  }
}

/// Horizontally scrolling suggestion chips.
///
/// Shows common hobby starting points. Tapping a chip populates
/// the input and immediately dispatches [DiscoverySubmitted].
class _SuggestionChips extends StatelessWidget {
  const _SuggestionChips();

  static const List<String> _suggestions = [
    'Beekeeping',
    'Home brewing',
    'Ceramics',
    'Film photography',
    'Rock climbing',
    'Keyboards',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('OR TAP A STARTING POINT', style: HobItTypography.agentLabel),
        const SizedBox(height: HobItSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _suggestions
                .map(
                  (label) => Padding(
                    padding: const EdgeInsets.only(right: HobItSpacing.sm),
                    child: ActionChip(
                      avatar: const Icon(
                        Icons.add,
                        size: 14,
                        color: HobItColors.navy,
                      ),
                      label: Text(label),
                      onPressed: () {
                        context.read<DiscoveryBloc>()
                          ..add(DiscoveryHobbyInputChanged(label))
                          ..add(const DiscoverySubmitted());
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

/// Pinned input bar fixed at the bottom of the Discover tab.
///
/// Pill-shaped text field with a circular navy send button.
/// Dispatches [DiscoveryHobbyInputChanged] on each keystroke and
/// [DiscoverySubmitted] on send.
class _PinnedInputBar extends StatelessWidget {
  const _PinnedInputBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: HobItSpacing.md,
        vertical: HobItSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: HobItColors.scaffold,
        border: Border(
          top: BorderSide(color: HobItColors.navy.withOpacity(0.1)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Message hob-it...',
                  filled: true,
                  fillColor: HobItColors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: HobItSpacing.md,
                    vertical: HobItSpacing.smd,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      HobItSpacing.radiusPill,
                    ),
                    borderSide: BorderSide(color: HobItColors.navy20),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      HobItSpacing.radiusPill,
                    ),
                    borderSide: BorderSide(color: HobItColors.navy20),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      HobItSpacing.radiusPill,
                    ),
                    borderSide: const BorderSide(
                      color: HobItColors.blue,
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (value) => context.read<DiscoveryBloc>().add(
                  DiscoveryHobbyInputChanged(value),
                ),
              ),
            ),
            const SizedBox(width: HobItSpacing.sm),
            BlocBuilder<DiscoveryBloc, DiscoveryState>(
              buildWhen: (previous, current) =>
                  previous.status != current.status,
              builder: (context, state) {
                return GestureDetector(
                  onTap: state.status == DiscoveryStatus.loading
                      ? null
                      : () => context.read<DiscoveryBloc>().add(
                          const DiscoverySubmitted(),
                        ),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: HobItColors.navy,
                      shape: BoxShape.circle,
                    ),
                    child: state.status == DiscoveryStatus.loading
                        ? const Padding(
                            padding: EdgeInsets.all(HobItSpacing.smd),
                            child: CircularProgressIndicator(
                              color: HobItColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.arrow_upward_rounded,
                            color: HobItColors.white,
                            size: 20,
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
