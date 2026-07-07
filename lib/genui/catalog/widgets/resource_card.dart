import 'package:flutter/material.dart';
import 'package:hob_it/ui/ui.dart';

/// A single resource within a [ResourceCard].
class ResourceItem {
  /// Creates a [ResourceItem].
  const ResourceItem({
    required this.category,
    required this.title,
    this.description,
    this.link,
    this.isFree = false,
  });

  /// A short lowercase category keyword: app, course, video, community,
  /// book, or a novel one the agent chose.
  final String category;

  /// The resource name.
  final String title;

  /// Optional one-line description.
  final String? description;

  /// Optional URL.
  final String? link;

  /// Whether the resource is free.
  final bool isFree;
}

/// A GenUI card listing learning and community resources for a hobby.
///
/// Reference material only: apps, courses, videos, communities, and books.
/// It has no action and does not complete a roadmap step, since resources
/// are explored rather than checked off. The learn/community step is marked
/// done on the roadmap itself.
class ResourceCard extends StatelessWidget {
  /// Creates a [ResourceCard].
  const ResourceCard({
    required this.title,
    required this.resources,
    this.subtitle,
    super.key,
  });

  /// The card headline.
  final String title;

  /// Optional supporting text shown below the title.
  final String? subtitle;

  /// The resources to display.
  final List<ResourceItem> resources;

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
            Text('RESOURCES', style: HobItTypography.categoryLabelFor('learn')),
            const SizedBox(height: HobItSpacing.xs),
            Text(title, style: textTheme.titleMedium),
            if (subtitle != null) ...[
              const SizedBox(height: HobItSpacing.xs),
              Text(
                subtitle!,
                style: textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: HobItSpacing.md),
            for (final resource in resources) _ResourceRow(resource: resource),
          ],
        ),
      ),
    );
  }
}

(IconData, String) _resourceMeta(String category) {
  return switch (category.trim().toLowerCase()) {
    'app' => (Icons.smartphone_rounded, 'App'),
    'course' => (Icons.school_rounded, 'Course'),
    'video' => (Icons.ondemand_video_rounded, 'Video'),
    'community' => (Icons.groups_rounded, 'Community'),
    'book' => (Icons.menu_book_rounded, 'Book'),
    _ => (Icons.link_rounded, 'Resource'),
  };
}

/// A single resource row: an icon tile, title, category, and free/paid tag.
class _ResourceRow extends StatelessWidget {
  const _ResourceRow({required this.resource});

  final ResourceItem resource;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (icon, label) = _resourceMeta(resource.category);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: HobItSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: HobItColors.iconTile,
              borderRadius: BorderRadius.circular(HobItSpacing.radiusXs),
            ),
            child: Icon(icon, size: 18, color: HobItColors.blue),
          ),
          const SizedBox(width: HobItSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        resource.title,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: HobItSpacing.sm),
                    _FreeTag(isFree: resource.isFree),
                  ],
                ),
                Text(label.toUpperCase(), style: textTheme.labelSmall),
                if (resource.description != null) ...[
                  const SizedBox(height: 2),
                  Text(resource.description!, style: textTheme.bodySmall),
                ],
              ],
            ),
          ),
          if (resource.link != null) ...[
            const SizedBox(width: HobItSpacing.sm),
            const Icon(
              Icons.open_in_new_rounded,
              size: 16,
              color: HobItColors.blue,
            ),
          ],
        ],
      ),
    );
  }
}

/// A small "Free" or "Paid" tag.
class _FreeTag extends StatelessWidget {
  const _FreeTag({required this.isFree});

  final bool isFree;

  @override
  Widget build(BuildContext context) {
    final (label, color) = isFree
        ? ('Free', HobItColors.green)
        : ('Paid', HobItColors.navy40);
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
