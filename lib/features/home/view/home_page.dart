import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genui/genui.dart';
import 'package:hob_it/features/features.dart';
import 'package:hob_it/features/home/bloc/home_bloc.dart';
import 'package:hob_it/genui/home_conversation.dart';
import 'package:hob_it/ui/ui.dart';
import 'package:hobby_repository/hobby_repository.dart';

/// The Home tab — a memory-driven feed of agent-generated surfaces.
///
/// Provides [HomeBloc] and kicks off lazy generation, then delegates to
/// [HomeView].
class HomePage extends StatelessWidget {
  /// Creates a [HomePage].
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(
        homeConversation: HomeConversation(),
        hobbyRepository: context.read<HobbyRepository>(),
      )..add(const HomeStarted()),
      child: const HomeView(),
    );
  }
}

/// Renders the home feed across its loading, ready, empty, and error states.
class HomeView extends StatelessWidget {
  /// Creates a [HomeView].
  const HomeView({super.key});

  static String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'GOOD MORNING';
    if (hour < 17) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }

  @override
  Widget build(BuildContext context) {
    final conversation = context.read<HomeBloc>().conversation;

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async {
            final bloc = context.read<HomeBloc>();
            bloc.add(const HomeRefreshRequested());
            await bloc.stream.firstWhere((s) => s.status != HomeStatus.loading);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: HobItSpacing.lg,
              vertical: HobItSpacing.md,
            ),
            children: [
              Text(_greeting, style: HobItTypography.agentLabel),
              const SizedBox(height: HobItSpacing.xs),
              Text(
                _headline(state.status),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: HobItSpacing.lg),
              ..._content(context, state, conversation),
            ],
          ),
        );
      },
    );
  }

  String _headline(HomeStatus status) {
    return switch (status) {
      HomeStatus.empty => 'Start something new',
      HomeStatus.failure => 'Something went wrong',
      _ => 'Pick up where you left off',
    };
  }

  List<Widget> _content(
    BuildContext context,
    HomeState state,
    HomeConversation conversation,
  ) {
    switch (state.status) {
      case HomeStatus.initial:
      case HomeStatus.loading:
        return const [_HomeLoading()];
      case HomeStatus.empty:
        return const [_StartSomethingNewTile()];
      case HomeStatus.failure:
        return const [_HomeError()];
      case HomeStatus.ready:
        return [
          for (final id in state.surfaceIds)
            Padding(
              padding: const EdgeInsets.only(bottom: HobItSpacing.md),
              child: Surface(surfaceContext: conversation.host.contextFor(id)),
            ),
          const SizedBox(height: HobItSpacing.sm),
          const _StartSomethingNewTile(),
        ];
    }
  }
}

/// Loading state shown while the agent generates the feed.
class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: HobItSpacing.xxl),
      child: Column(
        children: [
          const CircularProgressIndicator(color: HobItColors.blue),
          const SizedBox(height: HobItSpacing.md),
          Text(
            'Putting together your home…',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Error state with a retry action.
class _HomeError extends StatelessWidget {
  const _HomeError();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "We couldn't build your home feed. Pull to refresh or try again.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: HobItSpacing.md),
        FilledButton(
          onPressed: () =>
              context.read<HomeBloc>().add(const HomeRefreshRequested()),
          child: const Text('Try again'),
        ),
        const SizedBox(height: HobItSpacing.lg),
        const _StartSomethingNewTile(),
      ],
    );
  }
}

/// Quick-action tile that takes the user to the Discover tab.
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
          context.read<DiscoveryBloc>().add(
            const DiscoveryNewSessionRequested(),
          );
          context.read<ShellTabCubit>().openDiscover();
        },
      ),
    );
  }
}
