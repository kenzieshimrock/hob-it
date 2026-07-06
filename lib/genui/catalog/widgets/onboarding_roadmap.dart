import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:hob_it/ui/ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hob_it/features/discovery/bloc/discovery_bloc.dart';

/// A single step within an [OnboardingRoadmap].
class RoadmapStep {
  /// Creates a [RoadmapStep].
  const RoadmapStep({
    required this.id,
    required this.title,
    required this.category,
    required this.order,
    this.description,
    this.dependsOn = const [],
  });

  /// Stable id within the roadmap (the step order as a string).
  final String id;

  /// The step headline.
  final String title;

  /// A short lowercase category keyword.
  final String category;

  /// Optional supporting detail.
  final String? description;

  /// The 1-based position in the journey.
  final int order;

  /// Ids of steps that must be complete before this one is available.
  final List<String> dependsOn;
}

/// A GenUI card presenting the onboarding journey for a hobby.
///
/// Announces its steps on first build, dispatches per-step start and toggle
/// events, and locks any step whose prerequisites are not yet complete.
class OnboardingRoadmap extends StatefulWidget {
  /// Creates an [OnboardingRoadmap].
  const OnboardingRoadmap({
    required this.itemContext,
    required this.hobbyName,
    required this.steps,
    super.key,
  });

  /// The GenUI item context used to dispatch events.
  final CatalogItemContext itemContext;

  /// The hobby this roadmap is for.
  final String hobbyName;

  /// The ordered steps that make up the journey.
  final List<RoadmapStep> steps;

  @override
  State<OnboardingRoadmap> createState() => _OnboardingRoadmapState();
}

class _OnboardingRoadmapState extends State<OnboardingRoadmap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.itemContext.dispatchEvent(
        UserActionEvent(
          name: 'roadmapGenerated',
          sourceComponentId: widget.itemContext.id,
          context: {
            'steps': [
              for (final step in widget.steps)
                {
                  'id': step.id,
                  'title': step.title,
                  'category': step.category,
                  'dependsOn': step.dependsOn,
                },
            ],
          },
        ),
      );
    });
  }

  void _toggleStep(RoadmapStep step, Set<String> completed) {
    // Locked steps cannot be completed.
    if (step.dependsOn.any((id) => !completed.contains(id))) return;
    final nowComplete = !completed.contains(step.id);
    widget.itemContext.dispatchEvent(
      UserActionEvent(
        name: 'roadmapStepToggled',
        sourceComponentId: widget.itemContext.id,
        context: {'stepId': step.id, 'isComplete': nowComplete},
      ),
    );
  }

  void _onStartStep(RoadmapStep step) {
    widget.itemContext.dispatchEvent(
      UserActionEvent(
        name: 'roadmapStepStarted',
        sourceComponentId: widget.itemContext.id,
        context: {
          'hobbyName': widget.hobbyName,
          'stepId': step.id,
          'title': step.title,
          'category': step.category,
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final completed = context.select<DiscoveryBloc, Set<String>>(
      (bloc) => bloc.state.completedStepIds,
    );

    bool isLocked(RoadmapStep step) =>
        step.dependsOn.any((id) => !completed.contains(id));

    return Card(
      margin: EdgeInsets.zero,
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
            Text('ROADMAP', style: HobItTypography.categoryLabelFor('roadmap')),
            const SizedBox(height: HobItSpacing.xs),
            Text(
              'Your ${widget.hobbyName} journey',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: HobItSpacing.md),
            for (var i = 0; i < widget.steps.length; i++)
              _StepRow(
                step: widget.steps[i],
                isLast: i == widget.steps.length - 1,
                isDone: completed.contains(widget.steps[i].id),
                isLocked: isLocked(widget.steps[i]),
                onToggle: () => _toggleStep(widget.steps[i], completed),
                onStart: () => _onStartStep(widget.steps[i]),
              ),
          ],
        ),
      ),
    );
  }
}

/// A single timeline row: an indicator, the step's text, and a start action.
///
/// Locked steps show a lock, hide the start button, and cannot be toggled.
class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.isLast,
    required this.isDone,
    required this.isLocked,
    required this.onToggle,
    required this.onStart,
  });

  final RoadmapStep step;
  final bool isLast;
  final bool isDone;
  final bool isLocked;
  final VoidCallback onToggle;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = HobItColors.categoryColorFor(step.category);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              GestureDetector(
                onTap: isLocked ? null : onToggle,
                child: Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDone
                        ? HobItColors.green
                        : isLocked
                        ? HobItColors.navy20
                        : color,
                    shape: BoxShape.circle,
                  ),
                  child: isDone
                      ? const Icon(
                          Icons.check_rounded,
                          color: HobItColors.white,
                          size: 16,
                        )
                      : isLocked
                      ? const Icon(
                          Icons.lock_rounded,
                          color: HobItColors.navy40,
                          size: 14,
                        )
                      : Text(
                          '${step.order}',
                          style: textTheme.labelMedium?.copyWith(
                            color: HobItColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: HobItColors.navy20)),
            ],
          ),
          const SizedBox(width: HobItSpacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : HobItSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.category.toUpperCase(),
                    style: HobItTypography.categoryLabelFor(step.category),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.title,
                    style: textTheme.titleSmall?.copyWith(
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? HobItColors.navy40 : null,
                    ),
                  ),
                  if (step.description != null) ...[
                    const SizedBox(height: HobItSpacing.xs),
                    Text(step.description!, style: textTheme.bodySmall),
                  ],
                  if (!isDone && isLocked)
                    Padding(
                      padding: const EdgeInsets.only(top: HobItSpacing.sm),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lock_rounded,
                            size: 14,
                            color: HobItColors.navy40,
                          ),
                          const SizedBox(width: HobItSpacing.xs),
                          Text(
                            'Complete earlier steps first',
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    )
                  else if (!isDone)
                    Padding(
                      padding: const EdgeInsets.only(top: HobItSpacing.sm),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: onStart,
                          icon: const Icon(Icons.play_arrow_rounded, size: 16),
                          label: const Text('Start this step'),
                          style: TextButton.styleFrom(
                            foregroundColor: HobItColors.blue,
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(
                              horizontal: HobItSpacing.sm,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
