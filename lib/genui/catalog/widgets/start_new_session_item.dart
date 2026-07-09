import 'package:genui/genui.dart';
import 'package:hob_it/genui/catalog/widgets/start_new_session.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// The GenUI [CatalogItem] registration for [StartNewSession].
final CatalogItem startNewSessionItem = CatalogItem(
  name: 'StartNewSession',
  dataSchema: S.object(
    description:
        'Offers to start an isolated session for a different hobby the '
        'user mentioned mid-conversation, without losing the current '
        'session. Use only when the user is clearly pivoting to a new '
        'hobby, not asking a follow-up about the current one.',
    properties: {
      'message': S.string(
        description:
            'One sentence inviting the pivot, naming both hobbies, e.g. '
            '"Want to put rock climbing aside and explore beekeeping '
            'instead?"',
      ),
      'hobbyName': S.string(
        description: 'The new hobby to seed the fresh session with.',
      ),
      'ctaLabel': S.string(
        description:
            'Optional button label. Defaults to "Start {hobbyName} '
            'instead".',
      ),
    },
    required: ['message', 'hobbyName'],
  ),
  exampleData: [
    () => '''
{
  "message": "Want to put rock climbing aside and explore beekeeping instead?",
  "hobbyName": "Beekeeping",
  "ctaLabel": "Start beekeeping instead"
}
''',
  ],
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    return StartNewSession(
      itemContext: itemContext,
      message: data['message'] as String,
      hobbyName: data['hobbyName'] as String,
      ctaLabel: data['ctaLabel'] as String?,
    );
  },
);
