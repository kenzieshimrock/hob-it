import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:hob_it/ui/ui.dart';

/// A GenUI card recommending a single piece of gear for a hobby.
///
/// Renders an optional badge, the brand and product name, a short
/// rationale, an estimated price, and a primary action. When the user
/// taps the action button, dispatches a [UserActionEvent] named
/// `gearCardSelected` carrying the product [name] (and [link] when set).
///
/// Use this for one highlighted product. For a multi-item gear list,
/// use the StarterKit widget instead.
class GearCard extends StatelessWidget {
  /// Creates a [GearCard].
  const GearCard({
    required this.itemContext,
    required this.name,
    required this.price,
    required this.why,
    this.brand,
    this.imageUrl,
    this.link,
    this.badge,
    super.key,
  });

  /// The GenUI item context used to dispatch selection events to the agent.
  final CatalogItemContext itemContext;

  /// The product display name
  final String name;

  /// The price or price range as a display string, e.g. r"$80".
  final String price;

  /// One short sentence explaining why this item is recommended.
  final String why;

  /// Optional brand or manufacturer name shown above [name].
  final String? brand;

  /// Optional product image URL.
  ///
  /// Falls back to an icon tile when null or when the image fails to load.
  final String? imageUrl;

  /// Optional external link sent to the agent when the user taps the action.
  final String? link;

  /// Optional short badge, e.g. "Best value" or "Editor's pick".
  final String? badge;

  void _onSelect() {
    itemContext.dispatchEvent(
      UserActionEvent(
        name: 'gearCardSelected',
        sourceComponentId: itemContext.id,
        context: {'name': name, if (link != null) 'link': link},
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
              'GEAR',
              style: HobItTypography.categoryLabel(HobItCategory.gear),
            ),
            const SizedBox(height: HobItSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GearThumbnail(imageUrl: imageUrl),
                const SizedBox(width: HobItSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (badge != null) ...[
                        _Badge(label: badge!),
                        const SizedBox(height: HobItSpacing.xs),
                      ],
                      if (brand != null)
                        Text(brand!.toUpperCase(), style: textTheme.labelSmall),
                      Text(name, style: textTheme.titleMedium),
                      const SizedBox(height: HobItSpacing.xs),
                      Text(why, style: textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: HobItSpacing.sm),
                Text(price, style: HobItTypography.priceInline),
              ],
            ),
            const SizedBox(height: HobItSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _onSelect,
                child: Text(link != null ? 'View item' : 'Add to my gear'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A square product thumbnail with a graceful fallback.
///
/// Shows the network image at [imageUrl] when available, otherwise an
/// icon tile in the hob-it surface tone.
class _GearThumbnail extends StatelessWidget {
  const _GearThumbnail({this.imageUrl});

  final String? imageUrl;

  static const double _size = 56;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: HobItColors.iconTile,
        borderRadius: BorderRadius.circular(HobItSpacing.radiusXs),
      ),
      child: const Icon(Icons.backpack_outlined, color: HobItColors.amber),
    );

    final url = imageUrl;
    if (url == null) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(HobItSpacing.radiusXs),
      child: Image.network(
        url,
        width: _size,
        height: _size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => placeholder,
      ),
    );
  }
}

/// A small pill badge highlighting a product, e.g. "Best value".
class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: HobItSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: HobItColors.blue20,
        borderRadius: BorderRadius.circular(HobItSpacing.radiusXs),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: HobItColors.blue,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
