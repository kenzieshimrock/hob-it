import 'package:genui/genui.dart';
import 'package:hob_it/genui/catalog/widgets/proactive_nudge.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// The GenUI [CatalogItem] registration for [ProactiveNudge].
final CatalogItem proactiveNudgeItem = CatalogItem(
  name: 'ProactiveNudge',
  dataSchema: S.object(
    description:
        'A home-screen nudge following up on a past session or a completed '
        'step. Use on the home feed based on user memory.',
    properties: {
      'message': S.string(description: 'The nudge message.'),
      'contextSummary': S.string(
        description:
            'Optional short context, e.g. "Amateur radio · admin done".',
      ),
      'actionLabel': S.string(description: 'Optional action button label.'),
    },
    required: ['message'],
  ),
  exampleData: [
    () => '''
{
  "message": "You passed your Technician exam. Ready to pick a first radio?",
  "contextSummary": "Amateur radio · admin step complete",
  "actionLabel": "See starter radios"
}
''',
  ],
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    return ProactiveNudge(
      itemContext: itemContext,
      message: data['message'] as String,
      contextSummary: data['contextSummary'] as String?,
      actionLabel: data['actionLabel'] as String?,
    );
  },
);
