import 'dart:async';
import 'dart:convert';

import 'package:dartantic_ai/dartantic_ai.dart' as dartantic;
import 'package:flutter/foundation.dart';
import 'package:genui/genui.dart';
import 'package:hob_it/genui/catalog/widgets/widgets.dart';

/// Wires the GenUI [SurfaceController], [A2uiTransportAdapter], and a
/// Dartantic AI agent together for the hob-it Discovery flow.
///
/// Call [sendRequest] to send a user message. Listen to [surfaceUpdates]
/// to track surface lifecycle. Pass [host] to [Surface] widgets for rendering.
///
/// Dispose via [dispose] when the owning widget leaves the tree.
/// The Gemini API key must be supplied at run time via
/// `--dart-define=GEMINI_API_KEY=your_key`.
class HobbyConversation {
  /// Creates a [HobbyConversation] and initializes the GenUI pipeline.
  HobbyConversation() {
    _adapter = A2uiTransportAdapter();
    final catalog = BasicCatalogItems.asCatalog().copyWith(
      newItems: [
        adminChecklistItem,
        clarifyingCardItem,
        starterKitCatalogItem,
        gearCardItem,
        onboardingRoadmapItem,
        resourceCardItem,
      ],
    );
    _surfaceController = SurfaceController(catalogs: [catalog]);

    // Wire incoming A2UI messages from the adapter into the surface controller.
    _messageSub = _adapter.incomingMessages.listen(
      _surfaceController.handleMessage,
    );

    // listen for user interaction.
    _actionSub = _surfaceController.onSubmit.listen(_handleUserAction);

    _provider = dartantic.GoogleProvider(apiKey: _apiKey);

    _agent = dartantic.Agent.forProvider(
      _provider,
      chatModelName: 'gemini-2.5-flash',
    );

    // PromptBuilder generates the full A2UI format spec — including version,
    // widget catalog descriptions, and format constraints — automatically.
    final systemPrompt = PromptBuilder.chat(
      catalog: catalog,
      systemPromptFragments: [
        _hobbyAgentPrompt,
        PromptFragments.acknowledgeUser(),
        PromptFragments.requireAtLeastOneSubmitElement(
          prefix: PromptBuilder.defaultImportancePrefix,
        ),
        PromptFragments.uiGenerationRestriction(
          prefix: PromptBuilder.defaultImportancePrefix,
        ),
      ],
    ).systemPromptJoined();

    // Seed the system prompt as the first history item.
    _history.add(dartantic.ChatMessage.system(systemPrompt));
  }

  /// The hob-it agent persona fragment. Combined with A2UI format instructions
  /// by [PromptBuilder] to produce the full system prompt.
  static const String _hobbyAgentPrompt = '''
You are hob-it, a hobby onboarding companion. Always respond with
interactive UI cards from the catalog. Never reply with plain prose.

Conversation flow:
1. If the hobby or the user's intent is unclear, respond with a
   ClarifyingCard asking one focused question. Ask at most one before
   moving on.
2. Once you have enough context, respond with an OnboardingRoadmap as the
   primary overview: three to six ordered steps, each tagged with a
   category of gear, admin, learn, community, or other.
3. Set a step's dependsOn only for genuine prerequisites, for example a
   required license before buying gear. Most steps should have none so the
   user can approach them in any order.

Interactions arrive as a JSON payload with an action name and a context.
Respond to them as follows:
- roadmapStepStarted: read context.category and generate the card that
  fits that step.
  - gear: a StarterKit for a full kit, or a GearCard for one key item.
  - admin: an AdminChecklist of licenses, permits, or exams.
  - learn or community: a ResourceCard of apps, courses, videos,
    communities, and books.
- clarifyingOptionsSelected: use the selected value to continue the flow.

Sequencing: when a hobby is gated by admin steps, such as a license or
permit before buying gear, present the AdminChecklist before any
StarterKit, and mark the gear steps as depending on the admin step.

When you generate a card in response to a roadmapStepStarted interaction,
set that card's roadmapStepId to the started step's id (context.stepId),
so completing the card marks the matching roadmap step done.

Keep every response focused, hobby-specific, and rendered as UI.

''';

  /// The Gemini API key, supplied at build time via
  /// `--dart-define=GEMINI_API_KEY=your_key`.
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  late final A2uiTransportAdapter _adapter;
  late final SurfaceController _surfaceController;
  late final dartantic.GoogleProvider _provider;
  late final dartantic.Agent _agent;
  late final StreamSubscription<A2uiMessage> _messageSub;
  late final StreamSubscription<ChatMessage> _actionSub;

  /// Running conversation history, including the system prompt.
  final List<dartantic.ChatMessage> _history = [];

  /// Stream of [SurfaceUpdate] events (added, removed, updated).
  ///
  /// [DiscoveryBloc] subscribes to this to track surface IDs.
  Stream<SurfaceUpdate> get surfaceUpdates => _surfaceController.surfaceUpdates;

  /// Stream of raw text chunks streamed from the agent.
  ///
  /// Useful for showing a typing indicator in the feed.
  Stream<String> get incomingText => _adapter.incomingText;

  /// The [SurfaceHost] required by [Surface] widgets to render
  /// generated UI surfaces.
  SurfaceHost get host => _surfaceController;

  /// Sends [userMessage] to the agent as a plain human turn.
  ///
  /// Appends the message to history and triggers an agent response.
  Future<void> sendRequest(String userMessage) async {
    _history.add(dartantic.ChatMessage.user(userMessage));

    await _streamAgentResponse();
  }

  final StreamController<SurfaceProgressEvent> _progressController =
      StreamController<SurfaceProgressEvent>.broadcast();

  /// Local, non-agent interactions from generated surfaces.
  Stream<SurfaceProgressEvent> get progressActions =>
      _progressController.stream;

  /// Action names handled locally (persisted), never sent to the model.
  static const Set<String> _progressActionNames = {
    'roadmapGenerated',
    'roadmapStepToggled',
  };

  /// Handles a [ChatMessage] emitted by [SurfaceController.onSubmit].
  ///
  /// Converts the [UiInteractionPart] to a plain-text user message before
  /// sending to the agent. The Gemini API does not support the
  /// `application/vnd.genui.interaction+json` MIME type natively.
  Future<void> _handleUserAction(ChatMessage message) async {
    final interaction = _extractInteraction(message);

    if (interaction == null) {
      await sendRequest('[User submitted a UI interaction]');
      return;
    }

    if (_progressActionNames.contains(interaction.name)) {
      _progressController.add(
        SurfaceProgressEvent(
          name: interaction.name,
          context: interaction.context,
        ),
      );
      return; // handled locally; do not send to the agent
    }
    await sendRequest('[UI Interaction] ${interaction.raw}');
  }

  _ParsedInteraction? _extractInteraction(ChatMessage message) {
    for (final part in message.parts) {
      if (part.isUiInteractionPart) {
        final raw = part.asUiInteractionPart!.interaction;
        try {
          final decoded = jsonDecode(raw) as Map<String, dynamic>;
          final action = (decoded['action'] as Map).cast<String, dynamic>();
          return _ParsedInteraction(
            name: action['name'] as String? ?? '',
            context: (action['context'] as Map?)?.cast<String, dynamic>() ?? {},
            raw: raw,
          );
        } catch (_) {
          return _ParsedInteraction(name: '', context: const {}, raw: raw);
        }
      }
    }
    return null;
  }

  /// Streams an agent response using the current [_history] as full context.
  ///
  /// Called after a UI interaction message has already been appended to
  /// [_history] by [_handleUserAction]. Passes an empty string as the
  /// required message argument — the actual interaction content is carried
  /// by the [UiInteractionPart] already in history.
  Future<void> _streamAgentResponse() async {
    final buffer = StringBuffer();

    try {
      final stream = _agent.sendStream('', history: List.of(_history));

      await for (final result in stream) {
        if (result.output.isNotEmpty) {
          buffer.write(result.output);
          _adapter.addChunk(result.output);
        }
      }

      _history.add(dartantic.ChatMessage.model(buffer.toString()));
    } catch (e) {
      debugPrint('HobbyConversation: agent error — $e');
      rethrow;
    }
  }

  /// Disposes all GenUI and agent resources.
  ///
  /// Must be called when the owning widget is removed from the tree.
  void dispose() {
    _messageSub.cancel();
    _actionSub.cancel();
    _progressController.close();
    _adapter.dispose();
    _surfaceController.dispose();
  }
}

/// A local interaction from a generated surface (e.g. roadmap progress).
///
/// Consumed by [DiscoveryBloc] to persist progress. These are deliberately
/// NOT forwarded to the agent.
class SurfaceProgressEvent {
  /// Creates a [SurfaceProgressEvent].
  const SurfaceProgressEvent({required this.name, required this.context});

  /// The dispatched action name, e.g. `roadmapStepToggled`.
  final String name;

  /// The action payload.
  final Map<String, dynamic> context;
}

class _ParsedInteraction {
  const _ParsedInteraction({
    required this.name,
    required this.context,
    required this.raw,
  });

  final String name;
  final Map<String, dynamic> context;
  final String raw;
}
