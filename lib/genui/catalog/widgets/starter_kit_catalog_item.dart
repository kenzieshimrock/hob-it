import 'package:genui/genui.dart';
import 'package:hob_it/genui/catalog/widgets/starter_kit.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// The GenUI [CatalogItem] registration for [StarterKitWidget].
///
/// Instructs the agent to use this widget when it wants to present
/// a list of starter gear for a hobby with priority tiers and cost ranges.
final CatalogItem starterKitCatalogItem = CatalogItem(
  name: 'StarterKit',
  dataSchema: S.object(
    description:
        'A card listing the gear and items a user needs to start a hobby, '
        'grouped by priority and showing cost estimates.',
    properties: {
      'title': S.string(
        description:
            'Headline for the card, e.g. "Your Sourdough Starter Kit".',
      ),
      'subtitle': S.string(
        description: 'Optional supporting text shown below the title.',
      ),
      'items': S.list(
        description: 'Two to eight starter items ordered by priority.',
        items: S.object(
          properties: {
            'name': S.string(description: 'Item display name.'),
            'description': S.string(
              description: 'One short sentence describing the item.',
            ),
            'estimatedCost': S.string(
              description:
                  r'Cost range string, e.g. "$20–40". Omit if unknown.',
            ),
            'priority': S.string(
              description:
                  'One of: essential (must-have), helpful (nice-to-have), '
                  'optional (can skip initially).',
            ),
          },
          required: ['name', 'priority'],
        ),
      ),
      'totalEstimate': S.string(
        description:
            r'Total cost range across all items, e.g. "$150–250". '
            'Omit if not applicable.',
      ),
    },
    required: ['title', 'items'],
  ),
  exampleData: [
    () => r'''
{
  "title": "Your Sourdough Starter Kit",
  "subtitle": "Everything you need to bake your first loaf",
  "items": [
    { "name": "Dutch oven", "description": "Creates steam for a crispy crust.", "estimatedCost": "$40–80", "priority": "essential" },
    { "name": "Bench scraper", "description": "Shapes and transfers dough cleanly.", "estimatedCost": "$8–12", "priority": "essential" },
    { "name": "Kitchen scale", "description": "Weight measurements are far more accurate than cups.", "estimatedCost": "$15–25", "priority": "essential" },
    { "name": "Proofing basket (banneton)", "description": "Holds shape during the final proof.", "estimatedCost": "$15–25", "priority": "helpful" },
    { "name": "Lame (scoring blade)", "description": "Scores the dough before baking.", "estimatedCost": "$8–15", "priority": "helpful" },
    { "name": "Bread thermometer", "description": "Confirms the loaf is fully baked inside.", "estimatedCost": "$10–20", "priority": "optional" }
  ],
  "totalEstimate": "$96–177"
}
''',
  ],
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;

    StarterKitPriority parsePriority(String raw) => switch (raw) {
      'helpful' => StarterKitPriority.helpful,
      'optional' => StarterKitPriority.optional,
      _ => StarterKitPriority.essential,
    };

    final items = (data['items'] as List<dynamic>).map((raw) {
      final o = raw as Map<String, dynamic>;
      return StarterKitItem(
        name: o['name'] as String,
        description: o['description'] as String?,
        estimatedCost: o['estimatedCost'] as String?,
        priority: parsePriority((o['priority'] as String?) ?? 'essential'),
      );
    }).toList();

    return StarterKitWidget(
      itemContext: itemContext,
      title: data['title'] as String,
      subtitle: data['subtitle'] as String?,
      items: items,
      totalEstimate: data['totalEstimate'] as String?,
    );
  },
);
