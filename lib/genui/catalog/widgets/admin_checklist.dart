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

  /// The action the user must complete, e.g. "Pass the Technician exam".
  final String task;

  /// Whether this task is mandatory before starting the hobby.
  final bool isRequired;

  /// Optional URL with more detail, e.g. an exam-finder or registration page.
  final String? link;

  /// Optional human-readable time estimate, e.g. "2–3 hours".
  final String? estimatedTime;

  /// Optional cost string, e.g. r"$15".
  final String? cost;
}

/// A GenUI checklist of admin steps required before starting a hobby.
///
/// Renders licenses, permits, exams, and registrations as checkable rows.
/// Use before a StarterKit when a hobby is gated by admin steps. When the
/// user taps the primary action, dispatches a [UserActionEvent] named
/// `adminChecklistCompleted` carrying the labels of the checked tasks.
class AdminChecklist extends StatefulWidget {
  /// Creates an [AdminChecklist].
  const AdminChecklist({
    required this.itemContext,
    required this.title,
    required this.tasks,
    super.key,
  });

  /// The GenUI item context used to dispatch events to the agent.
  final CatalogItemContext itemContext;

  /// The card headline, e.g. "Before you start: amateur radio".
  final String title;

  /// The administrative tasks to display.
  final List<AdminTask> tasks;

  @override
  State<AdminChecklist> createState() => _AdminChecklistState();
}

class _AdminChecklistState extends State<AdminChecklist> {
  final Set<int> _checked = {};

  void _toggle(int index) {
    setState(() {
      if (!_checked.add(index)) _checked.remove(index);
    });
  }

  void _onSubmit() {
    final completed = [
      for (var i = 0; i < widget.tasks.length; i++)
        if (_checked.contains(i)) widget.tasks[i].task,
    ];
    widget.itemContext.dispatchEvent(
      UserActionEvent(
        name: 'adminChecklistCompleted',
        sourceComponentId: widget.itemContext.id,
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
            Text(
              'ADMIN',
              style: HobItTypography.categoryLabel(HobItCategory.admin),
            ),
            const SizedBox(height: HobItSpacing.xs),
            Text(widget.title, style: textTheme.titleMedium),
            const SizedBox(height: HobItSpacing.md),
            for (var i = 0; i < widget.tasks.length; i++)
              _TaskRow(
                task: widget.tasks[i],
                isChecked: _checked.contains(i),
                onToggle: () => _toggle(i),
              ),
            const SizedBox(height: HobItSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _onSubmit,
                child: const Text('Mark complete'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single checkable row inside an [AdminChecklist].
class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.task,
    required this.isChecked,
    required this.onToggle,
  });

  final AdminTask task;
  final bool isChecked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final meta = [
      if (task.estimatedTime != null) task.estimatedTime!,
      if (task.cost != null) task.cost!,
    ].join('  ·  ');

    return Padding(
      padding: const EdgeInsets.only(bottom: HobItSpacing.smd),
      child: InkWell(
        onTap: onToggle,
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
