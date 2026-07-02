import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genui/genui.dart';
import 'package:hob_it/features/discovery/bloc/discovery_bloc.dart';
import 'package:hob_it/genui/hobby_conversation.dart';
import 'package:hob_it/ui/ui.dart';
import 'package:hobby_repository/hobby_repository.dart';

/// The Discover tab — entry point for starting a new hobby discovery.
///
/// Provides [DiscoveryBloc] to the widget subtree and delegates rendering to
/// [DiscoveryView]. Reads the app-provided [HobbyRepository].
class DiscoveryPage extends StatelessWidget {
  /// Creates a [DiscoveryPage].
  const DiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DiscoveryBloc(
        conversation: HobbyConversation(),
        hobbyRepository: context.read<HobbyRepository>(),
      ),
      child: const DiscoveryView(),
    );
  }
}

/// The visual layer of the Discover tab.
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

/// Scrollable feed of the agent intro, suggestion chips, the conversation
/// (user messages and generated surfaces), and a typing indicator.
///
/// Auto-scrolls to the newest content as items arrive.
class _DiscoveryFeed extends StatefulWidget {
  const _DiscoveryFeed();

  @override
  State<_DiscoveryFeed> createState() => _DiscoveryFeedState();
}

class _DiscoveryFeedState extends State<_DiscoveryFeed> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final hobbyConversation = context.read<DiscoveryBloc>().conversation;
    return BlocConsumer<DiscoveryBloc, DiscoveryState>(
      listenWhen: (previous, current) =>
          previous.items.length != current.items.length ||
          previous.isResponding != current.isResponding,
      listener: (context, state) => _scrollToBottom(),
      buildWhen: (previous, current) =>
          previous.items != current.items ||
          previous.isResponding != current.isResponding,
      builder: (context, state) {
        return ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(HobItSpacing.lg),
          children: [
            const _AgentIntroMessage(),
            const SizedBox(height: HobItSpacing.md),
            const _SuggestionChips(),
            if (state.items.isNotEmpty) ...[
              const SizedBox(height: HobItSpacing.lg),
              for (final item in state.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: HobItSpacing.md),
                  child: switch (item) {
                    UserMessageItem(:final text) => _UserMessage(text: text),
                    AgentSurfaceItem(:final surfaceId) => Surface(
                      surfaceContext: hobbyConversation.host.contextFor(
                        surfaceId,
                      ),
                    ),
                  },
                ),
            ],
            if (state.isResponding) ...[
              const SizedBox(height: HobItSpacing.sm),
              const _TypingIndicator(),
            ],
          ],
        );
      },
    );
  }
}

/// A right-aligned bubble showing a message the user sent.
class _UserMessage extends StatelessWidget {
  const _UserMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(HobItSpacing.md),
            decoration: const BoxDecoration(
              color: HobItColors.blue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: Text(
              text,
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

/// A "hob-it is thinking" bubble shown while the agent streams a response.
class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
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
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: HobItSpacing.md,
            vertical: HobItSpacing.smd,
          ),
          decoration: const BoxDecoration(
            color: HobItColors.navy,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: const _TypingDots(),
        ),
      ],
    );
  }
}

/// Three dots that pulse in a wave to suggest the agent is working.
class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = _controller.value * 2 * math.pi - i * 0.9;
            final opacity = 0.4 + 0.5 * (0.5 + 0.5 * math.sin(phase));
            return Padding(
              padding: EdgeInsets.only(right: i < 2 ? HobItSpacing.xs : 0),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: HobItColors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Agent intro message bubble introducing hob-it.
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
          decoration: const BoxDecoration(
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
            decoration: const BoxDecoration(
              color: HobItColors.navy,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Text(
              "Hi, I'm hob-it. Tell me any hobby you'd like to try — "
              "I'll sort out the gear, admin, learning and community "
              'to get you started.',
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

/// Horizontally scrolling suggestion chips of common starting points.
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
/// Owns a [TextEditingController] so it can clear on send. Submits on the
/// send button or the keyboard action.
class _PinnedInputBar extends StatefulWidget {
  const _PinnedInputBar();

  @override
  State<_PinnedInputBar> createState() => _PinnedInputBarState();
}

class _PinnedInputBarState extends State<_PinnedInputBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final bloc = context.read<DiscoveryBloc>();
    if (bloc.state.status == DiscoveryStatus.loading) return;
    if (_controller.text.trim().isEmpty) return;
    bloc.add(const DiscoverySubmitted());
    _controller.clear();
  }

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
          top: BorderSide(color: HobItColors.navy.withValues(alpha: 0.1)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onChanged: (value) => context.read<DiscoveryBloc>().add(
                  DiscoveryHobbyInputChanged(value),
                ),
                onSubmitted: (_) => _submit(),
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
                      : _submit,
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
