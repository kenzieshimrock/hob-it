import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hob_it/features/features.dart';
import 'package:hob_it/ui/ui.dart';
import 'package:hobby_repository/hobby_repository.dart';

/// The Hobbies tab — a list of hobbies the user has started, with progress.
class HobbiesPage extends StatelessWidget {
  /// Creates a [HobbiesPage].
  const HobbiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HobbiesBloc(hobbyRepository: context.read<HobbyRepository>())
            ..add(const HobbiesSubscriptionRequested()),
      child: const HobbiesView(),
    );
  }
}

/// Renders the hobbies list, empty, loading, and error states.
class HobbiesView extends StatelessWidget {
  /// Creates a [HobbiesView].
  const HobbiesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HobbiesBloc, HobbiesState>(
      builder: (context, state) {
        return switch (state.status) {
          HobbiesStatus.initial || HobbiesStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          HobbiesStatus.failure => const _HobbiesMessage(
            icon: Icons.error_outline_rounded,
            title: 'Something went wrong',
            body: 'We could not load your hobbies. Try again later.',
          ),
          HobbiesStatus.success =>
            state.hobbies.isEmpty
                ? const _HobbiesMessage(
                    icon: Icons.layers_outlined,
                    title: 'No hobbies yet',
                    body:
                        'Start exploring one in the Discover tab and it '
                        'will show up here.',
                  )
                : _HobbiesList(hobbies: state.hobbies),
        };
      },
    );
  }
}

/// The scrollable list of hobby cards.
class _HobbiesList extends StatelessWidget {
  const _HobbiesList({required this.hobbies});

  final List<Hobby> hobbies;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(HobItSpacing.lg),
      itemCount: hobbies.length,
      itemBuilder: (context, index) => _HobbyCard(hobby: hobbies[index]),
    );
  }
}

/// A single hobby with its name, progress bar, and an Open action.
class _HobbyCard extends StatelessWidget {
  const _HobbyCard({required this.hobby});

  final Hobby hobby;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasSteps = hobby.totalCount > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: HobItSpacing.md),
      elevation: 0,
      color: HobItColors.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HobItSpacing.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(HobItSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(hobby.name, style: textTheme.titleMedium)),
                TextButton(
                  onPressed: () {
                    context.read<DiscoveryBloc>().add(
                      DiscoveryHobbyOpened(hobby.id),
                    );
                    context.read<ShellTabCubit>().openDiscover();
                  },
                  child: const Text('Open'),
                ),
              ],
            ),
            const SizedBox(height: HobItSpacing.sm),
            if (hasSteps) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(HobItSpacing.radiusXs),
                child: LinearProgressIndicator(
                  value: hobby.progress,
                  minHeight: 8,
                  backgroundColor: HobItColors.navy20,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    HobItColors.blue,
                  ),
                ),
              ),
              const SizedBox(height: HobItSpacing.xs),
              Text(
                '${hobby.completedCount} of ${hobby.totalCount} steps done',
                style: textTheme.bodySmall,
              ),
            ] else
              Text('Journey not started yet', style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// A centered icon-plus-text panel for the empty and error states.
class _HobbiesMessage extends StatelessWidget {
  const _HobbiesMessage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(HobItSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: HobItColors.navy40),
            const SizedBox(height: HobItSpacing.md),
            Text(title, style: textTheme.titleMedium),
            const SizedBox(height: HobItSpacing.xs),
            Text(body, textAlign: TextAlign.center, style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
