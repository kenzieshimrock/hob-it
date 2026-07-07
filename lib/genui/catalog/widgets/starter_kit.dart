import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:hob_it/ui/ui.dart';

/// Priority tier for a [StarterKitItem].
enum StarterKitPriority {
  /// Must-have to get started.
  essential,

  /// Nice to have but not blocking.
  helpful,

  /// Can be skipped initially.
  optional,
}

/// A single item in the starter kit list.
class StarterKitItem {
  /// Creates a [StarterKitItem].
  const StarterKitItem({
    required this.name,
    this.description,
    this.estimatedCost,
    this.priority = StarterKitPriority.essential,
  });

  /// The display name of the item.
  final String name;

  /// Optional supporting description.
  final String? description;

  /// Optional cost range.
  final String? estimatedCost;

  /// How important this item is for getting started.
  final StarterKitPriority priority;
}

/// A GenUI card listing starter gear the user checks off as owned.
///
/// Each item's checked state is bound to this surface's DataModel at a
/// relative `checked.<index>` path, so it survives scrolling. When every
/// "must" (essential) item is checked, the card marks its [roadmapStepId]
/// complete via a `roadmapStepToggled` event; unchecking a must item marks
/// it incomplete again. There is no submit button, so it never triggers an
/// agent turn.
class StarterKitWidget extends StatelessWidget {
  /// Creates a [StarterKitWidget].
  const StarterKitWidget({
    required this.itemContext,
    required this.title,
    required this.items,
    this.subtitle,
    this.totalEstimate,
    this.roadmapStepId,
    super.key,
  });

  /// The GenUI item context used to dispatch events and reach the DataModel.
  final CatalogItemContext itemContext;

  /// The card headline.
  final String title;

  /// Optional supporting text shown below the title.
  final String? subtitle;

  /// The list of items to display.
  final List<StarterKitItem> items;

  /// Optional total cost estimate shown in the footer.
  final String? totalEstimate;

  /// The roadmap step this kit completes, if generated from one.
  final String? roadmapStepId;

  /// Indices whose completion gates the roadmap step: the essential items,
  /// or all items when the agent marked none as essential.
  List<int> get _requiredIndices {
    final essentials = [
      for (var i = 0; i < items.length; i++)
        if (items[i].priority == StarterKitPriority.essential) i,
    ];
    if (essentials.isNotEmpty) return essentials;
    return [for (var i = 0; i < items.length; i++) i];
  }

  void _onToggle(int index, {required bool nowChecked}) {
    itemContext.dataContext.update(DataPath('checked.$index'), nowChecked);

    final stepId = roadmapStepId;
    if (stepId == null) return;

    // Only the must-have items gate the roadmap step, so ignore the rest.
    if (!_requiredIndices.contains(index)) return;

    final allRequiredChecked = _requiredIndices.every(
      (i) =>
          itemContext.dataContext.getValue<bool>(DataPath('checked.$i')) ??
          false,
    );
    itemContext.dispatchEvent(
      UserActionEvent(
        name: 'roadmapStepToggled',
        sourceComponentId: itemContext.id,
        context: {'stepId': stepId, 'isComplete': allRequiredChecked},
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
            _Header(title: title, subtitle: subtitle),
            const SizedBox(height: HobItSpacing.xs),
            Text(
              'Check off what you already have.',
              style: textTheme.bodySmall?.copyWith(color: HobItColors.navy40),
            ),
            const SizedBox(height: HobItSpacing.sm),
            for (var i = 0; i < items.length; i++)
              _ItemTile(
                item: items[i],
                dataContext: itemContext.dataContext,
                path: 'checked.$i',
                onToggle: (nowChecked) => _onToggle(i, nowChecked: nowChecked),
              ),
            if (totalEstimate != null) ...[
              const SizedBox(height: HobItSpacing.sm),
              _TotalRow(estimate: totalEstimate!),
            ],
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (subtitle != null) ...[
          const SizedBox(height: HobItSpacing.xs),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// A checkable starter-kit row bound to the DataModel at [path].
class _ItemTile extends StatelessWidget {
  const _ItemTile({
    required this.item,
    required this.dataContext,
    required this.path,
    required this.onToggle,
  });

  final StarterKitItem item;
  final DataContext dataContext;
  final String path;
  final ValueChanged<bool> onToggle;

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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: HobItSpacing.xs / 2),
      child: InkWell(
        onTap: () => onToggle(!isChecked),
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
            _PriorityBadge(priority: item.priority),
            const SizedBox(width: HobItSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                      color: isChecked ? HobItColors.navy40 : null,
                    ),
                  ),
                  if (item.description != null)
                    Text(
                      item.description!,
                      style: textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (item.estimatedCost != null) ...[
              const SizedBox(width: HobItSpacing.sm),
              Text(
                item.estimatedCost!,
                style: textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final StarterKitPriority priority;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (priority) {
      StarterKitPriority.essential => ('Must', HobItColors.green),
      StarterKitPriority.helpful => ('Good', HobItColors.blue),
      StarterKitPriority.optional => ('Extra', HobItColors.purple),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: HobItSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
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

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.estimate});

  final String estimate;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Estimated total',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          estimate,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
