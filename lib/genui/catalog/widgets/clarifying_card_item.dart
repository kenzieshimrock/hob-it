import 'package:genui/genui.dart';
import 'package:hob_it/genui/catalog/widgets/widgets.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// The [CatalogItem] registration for [ClarifyingCard].
///
/// Declares the data schema the agent must follow and maps incoming
/// A2UI component data to the Flutter widget.
final CatalogItem clarifyingCardItem = CatalogItem(
  name: 'ClarifyingCard',
  dataSchema: S.object(
    description:
        'A card presenting a clarifying question with selectable '
        "options. Use early in a discovery session to narrow down the user's "
        'intent before showing gear lists or roadmaps.',
    properties: {
      'title': S.string(description: 'The clarifying question headline.'),
      'subtitle': S.string(
        description: 'Optional supporting context shown below the title. ',
      ),
      'options': S.list(
        description: 'Two to four selectable answer options.',
        items: S.object(
          properties: {
            'label': S.string(description: 'Display text for the option.'),
            'value': S.string(
              description: 'Unique machine-readable identifier for the option.',
            ),
          },
          required: ['label', 'value'],
        ),
      ),
    },
    required: ['title', 'options'],
  ),
  exampleData: [
    () => '''
  [
    {
    "id": "root",
    "component": CarifyingCard",
    "title": "What kind of baking interests you the most?",
    "subtitle": "This helps me tailor your starter kit",
    "options": [
      {"label": "Bread and Sourdough", "value": "bread"},
      {"label": "Pastries and Cakes", "value": "pastries"},
      {"label": "Cookies and Bars", "value": "cookies"},
      {"label": "Not Sure Yet", "value": "unsure"},
     ]
    }
  ]
''',
  ],
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;

    return ClarifyingCard(
      itemContext: itemContext,
      title: data['title'] as String,
      subtitle: data['subtitle'] as String?,
      options: (data['options'] as List<dynamic>)
          .map(
            (o) => ClarifyingOption(
              label: o['label'] as String,
              value: o['value'] as String,
            ),
          )
          .toList(),
    );
  },
);
