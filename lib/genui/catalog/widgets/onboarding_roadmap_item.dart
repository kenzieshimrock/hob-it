import 'package:genui/genui.dart';
import 'package:hob_it/genui/catalog/widgets/onboarding_roadmap.dart';
import 'package:hob_it/ui/ui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// The GenUI [CatalogItem] registration for [OnboardingRoadmap].
///
/// Tells the agent to use this widget as the primary response once it has
/// gathered enough context to lay out the full journey for a hobby.
final CatalogItem onboardingRoadmapItem = CatalogItem(
  name: 'OnboardingRoadmap',
  dataSchema: S.object(
    description:
        'The full onboarding journey for a hobby, as an ordered list of '
        'steps. Use as the primary response once enough context is gathered. '
        'Each step is tagged with a category so the user sees the shape of '
        'the whole path.',
    properties: {
      'hobbyName': S.string(
        description: 'The hobby this roadmap is for, e.g. "Rock climbing".',
      ),
      'steps': S.list(
        description: 'Three to six ordered steps that make up the journey.',
        items: S.object(
          properties: {
            'title': S.string(description: 'Short step headline.'),
            'category': S.string(
              description:
                  'One of: gear, admin, learn, community. Drives tag color.',
            ),
            'description': S.string(
              description: 'One short sentence describing the step.',
            ),
            'order': S.integer(
              description: '1-based position of this step in the journey.',
            ),
          },
          required: ['title', 'category', 'order'],
        ),
      ),
    },
    required: ['hobbyName', 'steps'],
  ),
  exampleData: [
    () => '''
{
  "hobbyName": "Rock climbing",
  "steps": [
    {"title": "Join a climbing gym", "category": "community", "description": "Find a local gym with intro classes.", "order": 1},
    {"title": "Take a belay course", "category": "learn", "description": "Learn to belay safely before climbing with a partner.", "order": 2},
    {"title": "Get starter gear", "category": "gear", "description": "Shoes, harness, and a chalk bag are enough to begin.", "order": 3},
    {"title": "Find climbing partners", "category": "community", "description": "Use the gym board or local meetups.", "order": 4}
  ]
}
''',
  ],
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;

    HobItCategory parseCategory(String raw) => switch (raw) {
      'admin' => HobItCategory.admin,
      'learn' => HobItCategory.learn,
      'community' => HobItCategory.community,
      _ => HobItCategory.gear,
    };

    final steps = (data['steps'] as List<dynamic>).map((raw) {
      final o = raw as Map<String, dynamic>;
      return RoadmapStep(
        title: o['title'] as String,
        category: parseCategory(o['category'] as String? ?? 'gear'),
        description: o['description'] as String?,
        order: (o['order'] as num?)?.toInt() ?? 0,
      );
    }).toList()..sort((a, b) => a.order.compareTo(b.order));

    return OnboardingRoadmap(
      itemContext: itemContext,
      hobbyName: data['hobbyName'] as String,
      steps: steps,
    );
  },
);
