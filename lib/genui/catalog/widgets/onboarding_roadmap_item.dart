import 'package:genui/genui.dart';
import 'package:hob_it/genui/catalog/widgets/onboarding_roadmap.dart';
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
      'dependsOn': S.list(
        description:
            'Optional. The `order` numbers of steps that must be completed before '
            'this one becomes available. Use ONLY for genuine prerequisites, such '
            'as a license before buying gear. Leave empty for steps that can be '
            'done anytime.',
        items: S.integer(),
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
    final rawSteps = (data['steps'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    // All valid ids, for fail-open dependency filtering.
    final validIds = <String>{
      for (final o in rawSteps) '${(o['order'] as num?)?.toInt() ?? 0}',
    };

    final steps = rawSteps.map((o) {
      final order = (o['order'] as num?)?.toInt() ?? 0;
      final id = '$order';
      final dependsOn = ((o['dependsOn'] as List?) ?? const [])
          .map((e) => '${(e as num).toInt()}')
          .where((dep) => dep != id && validIds.contains(dep))
          .toList();
      return RoadmapStep(
        id: id,
        title: o['title'] as String,
        category: (o['category'] as String? ?? 'gear').trim().toLowerCase(),
        description: o['description'] as String?,
        order: order,
        dependsOn: dependsOn,
      );
    }).toList()..sort((a, b) => a.order.compareTo(b.order));

    return OnboardingRoadmap(
      itemContext: itemContext,
      hobbyName: data['hobbyName'] as String,
      steps: steps,
    );
  },
);
