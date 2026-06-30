import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:hob_it/ui/ui.dart';

/// A single step within an [OnboardingRoadmap].
class RoadmapStep {
  /// Creates a [RoadmapStep].
  const RoadmapStep({
    required this.title,
    required this.category,
    required this.order,
    this.description,
  });

  /// The step headline, e.g. "Join a climbing gym".
  final String title;

  /// The category this step belongs to, used for the colored tag.
  final HobItCategory category;

  /// Optional supporting detail shown below [title].
  final String? description;

  /// The 1-based position of this step in the journey.
  final int order;
}

/// A GenUI card presenting the full onboarding journey for a hobby.
///
/// Renders an ordered, category-tagged list of [RoadmapStep]s as a vertical
/// timeline. When the user taps the primary action, dispatches a
/// [UserActionEvent] named `roadmapStarted` carrying the [hobbyName].
class OnboardingRoadmap extends StatelessWidget {
  /// Creates an [OnboardingRoadmap].
  const OnboardingRoadmap({
    required this.itemContext,
    required this.hobbyName,
    required this.steps,
    super.key,
  });

  /// The GenUI item context used to dispatch events to the agent.
  final CatalogItemContext itemContext;

  /// The hobby this roadmap is for, e.g. "Rock climbing".
  final String hobbyName;

  /// The ordered steps that make up the journey.
  final List<RoadmapStep> steps;

  void _onStart() {
    itemContext.dispatchEvent(
      UserActionEvent(
        name: 'roadmapStarted',
        sourceComponentId: itemContext.id,
        context: {'hobbyName': hobbyName},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
            Text(
              'ROADMAP',
              style: HobItTypography.categoryLabel(HobItCategory.roadmap),
            ),
            const SizedBox(height: HobItSpacing.xs),
            Text('Your $hobbyName journey', style: textTheme.titleMedium),
            const SizedBox(height: HobItSpacing.md),
            for (var i = 0; i < steps.length; i++)
              _StepRow(step: steps[i], isLast: i == steps.length - 1),
            const SizedBox(height: HobItSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _onStart,
                child: const Text('Start my journey'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single timeline row: a numbered indicator joined by a connector line,
/// then the step's category tag, title, and optional description.
class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.isLast});

  final RoadmapStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = HobItColors.categoryColor(step.category);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Text(
                  '${step.order}',
                  style: textTheme.labelMedium?.copyWith(
                    color: HobItColors.white,
                    fontWeight: FontWeight.w700,
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
                    _categoryLabel(step.category),
                    style: HobItTypography.categoryLabel(step.category),
                  ),
                  const SizedBox(height: 2),
                  Text(step.title, style: textTheme.titleSmall),
                  if (step.description != null) ...[
                    const SizedBox(height: HobItSpacing.xs),
                    Text(step.description!, style: textTheme.bodySmall),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _categoryLabel(HobItCategory category) {
    return switch (category) {
      HobItCategory.community => 'COMMUNITY',
      HobItCategory.gear => 'GEAR',
      HobItCategory.learn => 'LEARN',
      HobItCategory.admin => 'ADMIN',
      HobItCategory.roadmap => 'ROADMAP',
    };
  }
}
