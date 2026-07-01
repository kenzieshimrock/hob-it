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
/// Each step is checkable. Completion is stored in this surface's DataModel
/// under a relative `completed.<order>` path, so tapping a step re-renders it
/// in place and the state survives surface rebuilds, with no round trip to
/// the agent. Note the DataModel is per-surface, so this state is local to
/// this roadmap card.
class OnboardingRoadmap extends StatelessWidget {
  /// Creates an [OnboardingRoadmap].
  const OnboardingRoadmap({
    required this.itemContext,
    required this.hobbyName,
    required this.steps,
    super.key,
  });

  /// The GenUI item context, used to dispatch events and reach the DataModel.
  final CatalogItemContext itemContext;

  /// The hobby this roadmap is for, e.g. "Rock climbing".
  final String hobbyName;

  /// The ordered steps that make up the journey.
  final List<RoadmapStep> steps;

  /// Relative DataModel key holding the per-step completion map.
  static const String _completedKey = 'completed';

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
    final dataContext = itemContext.dataContext;

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
            const SizedBox(height: HobItSpacing.xs),
            _ProgressCaption(
              dataContext: dataContext,
              completedKey: _completedKey,
              total: steps.length,
            ),
            const SizedBox(height: HobItSpacing.md),
            for (var i = 0; i < steps.length; i++)
              _StepRow(
                step: steps[i],
                isLast: i == steps.length - 1,
                dataContext: dataContext,
                path: '$_completedKey.${steps[i].order}',
              ),
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

/// A live "X of N done" caption bound to the step-completion map.
///
/// Subscribes to the parent `completed` map so it re-renders whenever any
/// step toggles.
class _ProgressCaption extends StatelessWidget {
  const _ProgressCaption({
    required this.dataContext,
    required this.completedKey,
    required this.total,
  });

  final DataContext dataContext;
  final String completedKey;
  final int total;

  @override
  Widget build(BuildContext context) {
    return BoundObject(
      dataContext: dataContext,
      value: {'path': completedKey},
      builder: (context, value) {
        final map = value is Map ? value : const <dynamic, dynamic>{};
        final done = map.values.where((v) => v == true).length;
        return Text(
          '$done of $total steps done',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: HobItColors.amber,
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }
}

/// A single timeline row whose completion state is bound to the DataModel.
///
/// Reads its done state via [BoundBool] and toggles it on tap by writing to
/// the same [path].
class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.isLast,
    required this.dataContext,
    required this.path,
  });

  final RoadmapStep step;
  final bool isLast;
  final DataContext dataContext;
  final String path;

  @override
  Widget build(BuildContext context) {
    return BoundBool(
      dataContext: dataContext,
      value: {'path': path},
      builder: (context, completed) =>
          _buildRow(context, isDone: completed ?? false),
    );
  }

  Widget _buildRow(BuildContext context, {required bool isDone}) {
    final textTheme = Theme.of(context).textTheme;
    final color = HobItColors.categoryColor(step.category);

    return IntrinsicHeight(
      child: InkWell(
        onTap: () => dataContext.update(DataPath(path), !isDone),
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
                      _categoryLabel(step.category),
                      style: HobItTypography.categoryLabel(step.category),
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
                  ],
                ),
              ),
            ),
          ],
        ),
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
