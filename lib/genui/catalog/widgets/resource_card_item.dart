import 'package:genui/genui.dart';
import 'package:hob_it/genui/catalog/widgets/resource_card.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// The GenUI [CatalogItem] registration for [ResourceCard].
///
/// Tells the agent to use this for learning and community resources,
/// typically in response to starting a learn or community roadmap step.
final CatalogItem resourceCardItem = CatalogItem(
  name: 'ResourceCard',
  dataSchema: S.object(
    description:
        'A card listing learning and community resources for a hobby: '
        'apps, courses, videos, communities, and books. Use for a learn or '
        'community step. Reference material only, with no action.',
    properties: {
      'title': S.string(
        description: 'Headline, e.g. "Learn and connect: rock climbing".',
      ),
      'subtitle': S.string(description: 'Optional supporting text.'),
      'items': S.list(
        description: 'Two to six resources.',
        items: S.object(
          properties: {
            'category': S.string(
              description:
                  'One of: app, course, video, community, book. Drives the '
                  'icon.',
            ),
            'title': S.string(description: 'Resource name.'),
            'description': S.string(
              description: 'One short sentence on what it offers.',
            ),
            'link': S.string(description: 'Optional URL. Omit if unknown.'),
            'free': S.boolean(description: 'True if the resource is free.'),
          },
          required: ['category', 'title'],
        ),
      ),
    },
    required: ['title', 'items'],
  ),
  exampleData: [
    () => '''
{
  "title": "Learn and connect: rock climbing",
  "subtitle": "A few places to build skills and find people",
  "items": [
    {"category": "video", "title": "Climbing basics series", "description": "Free beginner technique videos.", "free": true},
    {"category": "community", "title": "r/climbharder", "description": "Active subreddit for training advice.", "free": true},
    {"category": "app", "title": "Mountain Project", "description": "Route database and logbook.", "free": true},
    {"category": "course", "title": "Local gym intro class", "description": "Hands-on belay and safety basics.", "free": false}
  ]
}
''',
  ],
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;

    final resources = (data['items'] as List<dynamic>).map((raw) {
      final o = raw as Map<String, dynamic>;
      return ResourceItem(
        category: (o['category'] as String? ?? 'resource').trim().toLowerCase(),
        title: o['title'] as String,
        description: o['description'] as String?,
        link: o['link'] as String?,
        isFree: (o['free'] as bool?) ?? false,
      );
    }).toList();

    return ResourceCard(
      title: data['title'] as String,
      subtitle: data['subtitle'] as String?,
      resources: resources,
    );
  },
);
