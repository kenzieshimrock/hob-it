import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:hob_it/ui/ui.dart';

/// A single step within an [OnboardingRoadmap].
class RoadmapStep {
  /// Creates a [RoadmapStep].
  const RoadmapStep({
    required this.id,
    required this.title,
    required this.category,
    required this.order,
    this.description,
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
}

/// A GenUI card presenting the onboarding journey for a hobby.
///
/// On first build it dispatches `roadmapGenerated` carrying its steps so the
/// bloc can persist them. Tapping a step dispatches `roadmapStepToggled`.
/// Local state drives instant UI; the repository is the source of truth.
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
  final Set<String> _completed = {};

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
                },
            ],
          },
        ),
      );
    });
  }

  void _toggle(RoadmapStep step) {
    final nowComplete = !_completed.contains(step.id);
    setState(() {
      if (nowComplete) {
        _completed.add(step.id);
      } else {
        _completed.remove(step.id);
      }
    });
    widget.itemContext.dispatchEvent(
      UserActionEvent(
        name: 'roadmapStepToggled',
        sourceComponentId: widget.itemContext.id,
        context: {'stepId': step.id, 'isComplete': nowComplete},
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
              style: HobItTypography.categoryLabelFor('roadmap'),
            ),
            const SizedBox(height: HobItSpacing.xs),
            Text('Your ${widget.hobbyName} journey',
                style: textTheme.titleMedium),
            const SizedBox(height: HobItSpacing.md),
            for (var i = 0; i < widget.steps.length; i++)
              _StepRow(
                step: widget.steps[i],
                isLast: i == widget.steps.length - 1,
                isDone: _completed.contains(widget.steps[i].id),
                onTap: () => _toggle(widget.steps[i]),
              ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.isLast,
    required this.isDone,
    required this.onTap,
  });

  final RoadmapStep step;
  final bool isLast;
  final bool isDone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = HobItColors.categoryColorFor(step.category);

    return IntrinsicHeight(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HobItSpacing.radiusXs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDone ? HobItColors.green : color,
                    shape: BoxShape.circle,
                  ),
                  child: isDone
                      ? const Icon(
                          Icons.check_rounded,
                          color: HobItColors.white,
                          size: 16,
                        )
                      : Text(
                          '${step.order}',
                          style: textTheme.labelMedium?.copyWith(
                            color: HobItColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: HobItColors.navy20),
                  ),
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
                        decoration:
                            isDone ? TextDecoration.lineThrough : null,
                        color: isDone ? HobItColors.navy40 : null,
                      ),
                    ),
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
      ),
    );
  }
}
