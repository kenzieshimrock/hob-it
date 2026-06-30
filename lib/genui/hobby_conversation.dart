import 'dart:async';

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
      newItems: [clarifyingCardItem, starterKitCatalogItem, gearCardItem],
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
You are hob-it, a hobby discovery assistant. Help users explore a new hobby
by generating dynamic, interactive UI cards — not prose responses.

When a user describes a hobby, use the ClarifyingCard widget to ask one
focused clarifying question before proceeding. Then guide them through gear,
licenses, communities, and a growth path using the available widgets.
Keep responses focused and hobby-specific.
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

  /// Handles a [ChatMessage] emitted by [SurfaceController.onSubmit].
  ///
  /// Converts the [UiInteractionPart] to a plain-text user message before
  /// sending to the agent. The Gemini API does not support the
  /// `application/vnd.genui.interaction+json` MIME type natively.
  Future<void> _handleUserAction(ChatMessage message) async {
    debugPrint(
      'HobbyConversation: _handleUserAction called, parts: ${message.parts.length}',
    );

    final interactionText = _extractInteractionText(message);
    debugPrint('HobbyConversation: sending interaction text: $interactionText');

    await sendRequest(interactionText);
  }

  /// Finds the [UiInteractionPart] in [message] and formats it as a
  /// plain-text string the Gemini agent can understand.
  ///
  /// Falls back to a generic acknowledgement if no interaction part is found.
  String _extractInteractionText(ChatMessage message) {
    for (final part in message.parts) {
      if (part.isUiInteractionPart) {
        final interaction = part.asUiInteractionPart!;
        return '[UI Interaction] ${interaction.interaction}';
      }
    }
    return '[User submitted a UI interaction]';
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
    _adapter.dispose();
    _surfaceController.dispose();
  }
}
