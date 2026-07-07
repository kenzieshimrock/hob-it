import 'package:genui/genui.dart';
import 'package:hob_it/genui/catalog/widgets/recommended_hobby.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// The GenUI [CatalogItem] registration for [RecommendedHobby].
final CatalogItem recommendedHobbyItem = CatalogItem(
  name: 'RecommendedHobby',
  dataSchema: S.object(
    description:
        'A home-screen card that resurfaces a hobby the user showed interest '
        'in, inviting them to continue. Use on the home feed, based on the '
        'user memory provided in the system prompt.',
    properties: {
      'hobbyName': S.string(
        description: 'The hobby to resurface, e.g. "Film photography".',
      ),
      'reason': S.string(
        description: 'One sentence on why it is being suggested now.',
      ),
      'lastMentioned': S.string(
        description: 'Optional note on when it came up, e.g. "A while back".',
      ),
      'ctaLabel': S.string(
        description: 'Optional button label. Defaults to "Pick it back up".',
      ),
    },
    required: ['hobbyName', 'reason'],
  ),
  exampleData: [
    () => '''
{
  "hobbyName": "Film photography",
  "reason": "You mentioned wanting to try it a while back. Ready to start?",
  "lastMentioned": "Mentioned a few sessions ago",
  "ctaLabel": "Explore film photography"
}
''',
  ],
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    return RecommendedHobby(
      itemContext: itemContext,
      hobbyName: data['hobbyName'] as String,
      reason: data['reason'] as String,
      lastMentioned: data['lastMentioned'] as String?,
      ctaLabel: data['ctaLabel'] as String?,
    );
  },
);
