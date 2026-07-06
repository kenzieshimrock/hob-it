import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:hob_it/ui/ui.dart';

/// Represents a single item in the starter kit list.
class StarterKitItem {
  /// Creates a [StarterKitItem].
  const StarterKitItem({
    required this.name,
    this.description,
    this.estimatedCost,
    this.priority = StarterKitPriority.essential,
    this.roadmapStepId,
  });

  /// The display name of the item.
  final String name;

  /// Optional supporting description.
  final String? description;

  /// Optional cost range
  final String? estimatedCost;

  /// How important this item is for getting started.
  final StarterKitPriority priority;

  /// The roadmap step this checklist completes, if it was started from one.
  final String? roadmapStepId;
}

/// Priority tier for a [StarterKitItem].
enum StarterKitPriority {
  /// Must-have to get started.
  essential,

  /// Nice to have but not blocking.
  helpful,

  /// Can be skipped initially.
  optional,
}

/// A GenUI card that presents a categorized starter gear list.
///
/// Renders each [StarterKitItem] with a priority badge and optional cost.
/// Dispatches a [UserActionEvent] with name `starterKitAccepted` when the
/// user taps the primary action button.
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

  /// The GenUI item context used to dispatch events.
  final CatalogItemContext itemContext;

  /// The card headline.
  final String title;

  /// Optional supporting text shown below the title.
  final String? subtitle;

  /// The list of items to display.
  final List<StarterKitItem> items;

  /// Optional total cost estimate shown in the footer.
  final String? totalEstimate;

  /// The roadmap step this checklist completes, if it was started from one.
  final String? roadmapStepId;

  void _submit() {
    final stepId = roadmapStepId;

    if (stepId != null) {
      itemContext.dispatchEvent(
        UserActionEvent(
          name: 'starterKitAccepted',
          sourceComponentId: itemContext.id,
          context: const {},
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(HobItSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(title: title, subtitle: subtitle),
            const SizedBox(height: HobItSpacing.sm),
            ...items.map((item) => _ItemTile(item: item)),
            if (totalEstimate != null) ...[
              const SizedBox(height: HobItSpacing.sm),
              _TotalRow(estimate: totalEstimate!),
            ],
            const SizedBox(height: HobItSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: const Text("Let's go"),
              ),
            ),
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

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item});

  final StarterKitItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: HobItSpacing.xs / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PriorityBadge(priority: item.priority),
          const SizedBox(width: HobItSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (item.description != null)
                  Text(
                    item.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
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
