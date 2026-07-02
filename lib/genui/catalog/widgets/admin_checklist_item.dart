import 'package:genui/genui.dart';
import 'package:hob_it/genui/catalog/widgets/admin_checklist.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// The GenUI [CatalogItem] registration for [AdminChecklist].
///
/// Tells the agent to use this widget for licenses, permits, exams, and
/// registrations that must be handled before a hobby can begin. The agent
/// should present this before a StarterKit when a hobby is admin-gated.
final CatalogItem adminChecklistItem = CatalogItem(
  name: 'AdminChecklist',
  dataSchema: S.object(
    description:
        'A checklist of administrative steps — licenses, permits, exams, '
        'registrations — required before starting a hobby. Use this before '
        'a StarterKit when the hobby is gated by admin tasks, e.g. an '
        'amateur radio license exam.',
    properties: {
      'title': S.string(
        description: 'Headline, e.g. "Before you start: amateur radio".',
      ),
      'items': S.list(
        description: 'One to six administrative tasks.',
        items: S.object(
          properties: {
            'task': S.string(description: 'The action to complete.'),
            'required': S.boolean(
              description: 'True if mandatory before starting the hobby.',
            ),
            'link': S.string(
              description: 'Optional URL with more detail. Omit if unknown.',
            ),
            'estimatedTime': S.string(
              description: r'Optional time estimate, e.g. "2–3 hours".',
            ),
            'cost': S.string(
              description: r'Optional cost string, e.g. "$15". Omit if free.',
            ),
          },
          required: ['task', 'required'],
        ),
      ),
      'roadmapStepId': S.string(
        description:
            'Optional. The id of the roadmap step this checklist completes. '
            'Set it to the started step id so finishing the checklist marks that '
            'step done on the roadmap.',
      ),
    },
    required: ['title', 'items'],
  ),
  exampleData: [
    () => r'''
{
  "title": "Before you start: amateur radio",
  "items": [
    {"task": "Pass the Technician class license exam", "required": true, "link": "https://www.arrl.org/exam", "estimatedTime": "2–3 hours study", "cost": "$15"},
    {"task": "Register for an FCC FRN", "required": true, "estimatedTime": "15 minutes"},
    {"task": "Join a local amateur radio club", "required": false}
  ]
}
''',
  ],
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;

    final tasks = (data['items'] as List<dynamic>).map((raw) {
      final o = raw as Map<String, dynamic>;
      return AdminTask(
        task: o['task'] as String,
        isRequired: (o['required'] as bool?) ?? true,
        link: o['link'] as String?,
        estimatedTime: o['estimatedTime'] as String?,
        cost: o['cost'] as String?,
      );
    }).toList();

    return AdminChecklist(
      itemContext: itemContext,
      title: data['title'] as String,
      tasks: tasks,
      roadmapStepId: data['roadmapStepId'] as String?,
    );
  },
);
