import 'dart:async';
import 'dart:convert';

import 'package:dartantic_ai/dartantic_ai.dart' as dartantic;
import 'package:flutter/foundation.dart';
import 'package:genui/genui.dart';
import 'package:hob_it/genui/catalog/widgets/widgets.dart';

/// A navigation action from a home surface (e.g. a RecommendedHobby CTA).
///
/// Consumed by the home layer to route to Discover. It is NOT sent to the
/// agent.
class HomeNavigationAction {
  /// Creates a [HomeNavigationAction].
  const HomeNavigationAction({required this.name, required this.context});

  /// The dispatched action name.
  final String name;

  /// The action payload.
  final Map<String, dynamic> context;
}

/// Wires the GenUI pipeline for the memory-driven home feed.
///
/// Mirrors [HobbyConversation] but with a home catalog (RecommendedHobby,
/// ProactiveNudge) and a prompt that turns the user's memory into a short
/// personalized feed. Call [generateFeed] with a memory summary. Card CTAs
/// arrive on [navigationActions], filtered off the agent path.
///
/// The Gemini API key is supplied via `--dart-define=GEMINI_API_KEY=...`.
class HomeConversation {
  /// Creates a [HomeConversation] and initializes the GenUI pipeline.
  HomeConversation() {
    _adapter = A2uiTransportAdapter();

    final catalog = BasicCatalogItems.asCatalog().copyWith(
      newItems: [recommendedHobbyItem, proactiveNudgeItem],
    );
    _surfaceController = SurfaceController(catalogs: [catalog]);

    _messageSub = _adapter.incomingMessages.listen(
      _surfaceController.handleMessage,
    );
    _actionSub = _surfaceController.onSubmit.listen(_handleUserAction);

    _provider = dartantic.GoogleProvider(apiKey: _apiKey);
    _agent = dartantic.Agent.forProvider(
      _provider,
      chatModelName: 'gemini-2.5-flash',
    );

    _systemPrompt = PromptBuilder.chat(
      catalog: catalog,
      systemPromptFragments: [
        _homeAgentPrompt,
        PromptFragments.acknowledgeUser(),
        PromptFragments.requireAtLeastOneSubmitElement(
          prefix: PromptBuilder.defaultImportancePrefix,
        ),
        PromptFragments.uiGenerationRestriction(
          prefix: PromptBuilder.defaultImportancePrefix,
        ),
      ],
    ).systemPromptJoined();
  }

  /// The home agent persona. Combined with the A2UI format instructions by
  /// [PromptBuilder].
  static const String _homeAgentPrompt = '''
You are hob-it's home screen. Generate a short, personal feed of one to three
cards that invite the user back into hobbies they care about, using ONLY the
RecommendedHobby and ProactiveNudge widgets. Never reply with prose.

The user's memory is provided in the message: the hobbies they've started and
how far along each one is. Use it to:
- RecommendedHobby: resurface a hobby they started but have not finished, with
  a warm, specific reason to continue.
- ProactiveNudge: follow up on a completed step, or suggest the next move.

Keep it brief and specific to the memory provided.
''';

  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  late final A2uiTransportAdapter _adapter;
  late final SurfaceController _surfaceController;
  late final dartantic.GoogleProvider _provider;
  late final dartantic.Agent _agent;
  late final StreamSubscription<A2uiMessage> _messageSub;
  late final StreamSubscription<ChatMessage> _actionSub;
  late final String _systemPrompt;

  final List<dartantic.ChatMessage> _history = [];

  final StreamController<HomeNavigationAction> _navigationController =
      StreamController<HomeNavigationAction>.broadcast();

  /// Card CTA action names handled as navigation, never sent to the agent.
  static const Set<String> _navigationActionNames = {
    'recommendedHobbySelected',
    'proactiveNudgeSelected',
  };

  /// Surface lifecycle events for the home feed.
  Stream<SurfaceUpdate> get surfaceUpdates => _surfaceController.surfaceUpdates;

  /// Raw streamed text chunks, useful for a loading indicator.
  Stream<String> get incomingText => _adapter.incomingText;

  /// Card CTA actions routed to navigation rather than the agent.
  Stream<HomeNavigationAction> get navigationActions =>
      _navigationController.stream;

  /// The [SurfaceHost] required by [Surface] widgets.
  SurfaceHost get host => _surfaceController;

  /// Generates the home feed from a [memorySummary] of the user's hobbies.
  ///
  /// Resets the conversation first so each generation reflects only the
  /// current memory.
  Future<void> generateFeed(String memorySummary) async {
    _history
      ..clear()
      ..add(dartantic.ChatMessage.system(_systemPrompt))
      ..add(dartantic.ChatMessage.user('[User memory]\n$memorySummary'));
    await _streamAgentResponse();
  }

  /// Handles a [ChatMessage] from [SurfaceController.onSubmit].
  ///
  /// Home interactions are all navigation, so the matching ones are emitted
  /// on [navigationActions] and nothing is sent to the agent.
  void _handleUserAction(ChatMessage message) {
    final interaction = _extractInteraction(message);
    if (interaction == null) return;
    if (_navigationActionNames.contains(interaction.name)) {
      _navigationController.add(
        HomeNavigationAction(
          name: interaction.name,
          context: interaction.context,
        ),
      );
    }
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
          );
        } catch (_) {
          return null;
        }
      }
    }
    return null;
  }

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
      debugPrint('HomeConversation: agent error — $e');
      rethrow;
    }
  }

  /// Disposes all GenUI and agent resources.
  void dispose() {
    _messageSub.cancel();
    _actionSub.cancel();
    _navigationController.close();
    _adapter.dispose();
    _surfaceController.dispose();
  }
}

class _ParsedInteraction {
  const _ParsedInteraction({required this.name, required this.context});

  final String name;
  final Map<String, dynamic> context;
}
