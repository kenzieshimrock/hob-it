import 'package:genui/genui.dart';
import 'package:hob_it/genui/catalog/widgets/gear_card.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// The GenUI [CatalogItem] registration for [GearCard].
///
/// Declares the data schema the agent must follow and maps incoming
/// A2UI component data to the Flutter widget.
final CatalogItem gearCardItem = CatalogItem(
  name: 'GearCard',
  dataSchema: S.object(
    description:
        'A card recommending a single specific product for a hobby. Use '
        'when highlighting one item in detail. For a multi-item gear list, '
        'use StarterKit instead.',
    properties: {
      'name': S.string(description: 'Product display name.'),
      'price': S.string(
        description: r'Price or price range string, e.g. "$80" or "$60–90".',
      ),
      'why': S.string(
        description: 'One short sentence on why this item is recommended.',
      ),
      'brand': S.string(description: 'Optional brand or manufacturer name.'),
      'imageUrl': S.string(
        description: 'Optional product image URL. Omit if unknown.',
      ),
      'link': S.string(
        description: 'Optional URL to view or buy the item. Omit if unknown.',
      ),
      'badge': S.string(
        description: 'Optional short badge, e.g. "Best value".',
      ),
    },
    required: ['name', 'price', 'why'],
  ),
  exampleData: [
    () => r'''
{
  "name": "La Sportiva Tarantulace",
  "price": "$80",
  "why": "A forgiving, durable shoe that suits first-time climbers.",
  "brand": "La Sportiva",
  "badge": "Best for beginners"
}
''',
  ],
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;

    return GearCard(
      itemContext: itemContext,
      name: data['name'] as String,
      price: data['price'] as String,
      why: data['why'] as String,
      brand: data['brand'] as String?,
      imageUrl: data['imageUrl'] as String?,
      link: data['link'] as String?,
      badge: data['badge'] as String?,
    );
  },
);
