import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:hob_it/ui/ui.dart';

/// A single task within an [AdminChecklist].
class AdminTask {
  /// Creates an [AdminTask].
  const AdminTask({
    required this.task,
    this.isRequired = true,
    this.link,
    this.estimatedTime,
    this.cost,
  });

  /// The action the user must complete.
  final String task;

  /// Whether this task is mandatory before starting the hobby.
  final bool isRequired;

  /// Optional URL with more detail.
  final String? link;

  /// Optional human-readable time estimate.
  final String? estimatedTime;

  /// Optional cost string.
  final String? cost;
}

/// A GenUI checklist of admin steps required before starting a hobby.
///
/// Each task's checked state is bound to this surface's DataModel at a
/// relative `checked.<index>` path. The DataModel outlives the widget, so
/// the checks survive the widget being disposed and rebuilt, for example
/// when scrolled out of the feed. No keep-alive needed.
class AdminChecklist extends StatelessWidget {
  /// Creates an [AdminChecklist].
  const AdminChecklist({
    required this.itemContext,
    required this.title,
    required this.tasks,
    this.roadmapStepId,
    super.key,
  });

  /// The GenUI item context used to dispatch events and reach the DataModel.
  final CatalogItemContext itemContext;

  /// The card headline.
  final String title;

  /// The administrative tasks to display.
  final List<AdminTask> tasks;

  /// The roadmap step this checklist completes, if started from one.
  final String? roadmapStepId;

  void _submit() {
    final stepId = roadmapStepId;
    if (stepId != null) {
      itemContext.dispatchEvent(
        UserActionEvent(
          name: 'roadmapStepToggled',
          sourceComponentId: itemContext.id,
          context: {'stepId': stepId, 'isComplete': true},
        ),
      );
      return;
    }

    // Standalone checklist: read the ticked tasks from the DataModel.
    final completed = <String>[];
    for (var i = 0; i < tasks.length; i++) {
      final done =
          itemContext.dataContext.getValue<bool>(DataPath('checked.$i')) ??
          false;
      if (done) completed.add(tasks[i].task);
    }
    itemContext.dispatchEvent(
      UserActionEvent(
        name: 'adminChecklistCompleted',
        sourceComponentId: itemContext.id,
        context: {'completed': completed},
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
            Text('ADMIN', style: HobItTypography.categoryLabelFor('admin')),
            const SizedBox(height: HobItSpacing.xs),
            Text(title, style: textTheme.titleMedium),
            const SizedBox(height: HobItSpacing.md),
            for (var i = 0; i < tasks.length; i++)
              _TaskRow(
                task: tasks[i],
                dataContext: itemContext.dataContext,
                path: 'checked.$i',
              ),
            const SizedBox(height: HobItSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: const Text('Mark complete'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single checkable row bound to the DataModel at [path].
class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.task,
    required this.dataContext,
    required this.path,
  });

  final AdminTask task;
  final DataContext dataContext;
  final String path;

  @override
  Widget build(BuildContext context) {
    return BoundBool(
      dataContext: dataContext,
      value: {'path': path},
      builder: (context, checked) => _row(context, isChecked: checked ?? false),
    );
  }

  Widget _row(BuildContext context, {required bool isChecked}) {
    final textTheme = Theme.of(context).textTheme;
    final meta = [
      if (task.estimatedTime != null) task.estimatedTime!,
      if (task.cost != null) task.cost!,
    ].join('  ·  ');

    return Padding(
      padding: const EdgeInsets.only(bottom: HobItSpacing.smd),
      child: InkWell(
        onTap: () => dataContext.update(DataPath(path), !isChecked),
        borderRadius: BorderRadius.circular(HobItSpacing.radiusXs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isChecked
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: isChecked ? HobItColors.green : HobItColors.navy20,
              size: 22,
            ),
            const SizedBox(width: HobItSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(task.task, style: textTheme.bodyMedium),
                      ),
                      const SizedBox(width: HobItSpacing.sm),
                      _RequirementTag(isRequired: task.isRequired),
                    ],
                  ),
                  if (meta.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(meta, style: textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            if (task.link != null) ...[
              const SizedBox(width: HobItSpacing.sm),
              const Icon(
                Icons.open_in_new_rounded,
                size: 16,
                color: HobItColors.blue,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A small tag indicating whether a task is required or optional.
class _RequirementTag extends StatelessWidget {
  const _RequirementTag({required this.isRequired});

  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final (label, color) = isRequired
        ? ('Required', HobItColors.purple)
        : ('Optional', HobItColors.navy40);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: HobItSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(HobItSpacing.radiusXs),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
