import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:genui/genui.dart';
import 'package:hob_it/genui/hobby_conversation.dart';
import 'package:hobby_repository/hobby_repository.dart';

part 'discovery_event.dart';
part 'discovery_state.dart';

/// Manages state for the Discovery flow.
///
/// Owns a [HobbyConversation], persists the hobby via [HobbyRepository], and
/// translates GenUI surface events into [DiscoveryState] updates.
class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  /// Creates a [DiscoveryBloc].
  ///
  /// conversationFactory builds a fresh [HobbyConversation] for each
  /// session, so the bloc can start over or open a different hobby.
  DiscoveryBloc({
    required this._conversationFactory,
    required this._hobbyRepository,
  }) : super(const DiscoveryState()) {
    on<DiscoveryHobbyInputChanged>(_onHobbyInputChanged);
    on<DiscoverySubmitted>(_onSubmitted);
    on<DiscoveryNewSessionRequested>(_onNewSessionRequested);
    on<DiscoveryHobbyOpened>(_onHobbyOpened);
    on<_DiscoverySurfaceAdded>(_onSurfaceAdded);
    on<_DiscoverySurfaceRemoved>(_onSurfaceRemoved);
    on<_DiscoverySurfaceUpdated>(_onSurfaceUpdated);
    on<_DiscoveryAgentChunkReceived>(_onAgentChunkReceived);
    on<_DiscoveryStepsGenerated>(_onStepsGenerated);
    on<_DiscoveryStepToggled>(_onStepToggled);
    on<_DiscoveryHobbiesUpdated>(_onHobbiesUpdated);

    // Build the first conversation and wire up its streams.
    _conversation = _conversationFactory();
    _bindConversation();

    _hobbiesSubscription = _hobbyRepository.watchHobbies().listen(
      (hobbies) => add(_DiscoveryHobbiesUpdated(hobbies)),
      onError: addError,
    );
  }
  final HobbyConversation Function() _conversationFactory;
  final HobbyRepository _hobbyRepository;

  late HobbyConversation _conversation;
  late StreamSubscription<SurfaceUpdate> _surfaceSubscription;
  late StreamSubscription<SurfaceProgressEvent> _progressSubscription;
  late StreamSubscription<String> _textSubscription;
  late final StreamSubscription<List<Hobby>> _hobbiesSubscription;
  late final StreamSubscription<HobbySessionPivotEvent> _pivotSubscription;

  /// Exposes the current [HobbyConversation] so the view can render surfaces.
  HobbyConversation get conversation => _conversation;

  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();

  /// Updates [DiscoveryState.hobbyInput] as the user types.
  void _onHobbyInputChanged(
    DiscoveryHobbyInputChanged event,
    Emitter<DiscoveryState> emit,
  ) {
    emit(state.copyWith(hobbyInput: event.input));
  }

  /// Subscribes to the current conversation's streams.
  /// The conversation exposes three streams. The bloc's job is to
  /// translate each external stream event into an internal bloc event,
  /// so all the state changes flow through the same event -> handler path.
  void _bindConversation() {
    // 1) Surface lifecycle from the GenUI engine.
    _surfaceSubscription = _conversation.surfaceUpdates.listen((update) {
      switch (update) {
        case SurfaceAdded(:final surfaceId):
          add(_DiscoverySurfaceAdded(surfaceId));
        case SurfaceRemoved(:final surfaceId):
          add(_DiscoverySurfaceRemoved(surfaceId));
        case ComponentsUpdated():
          add(const _DiscoverySurfaceUpdated());
      }
    });

    // 2) Progress actions: local interactions (roadmap generated / step
    // toggled) that the conversation filtered OFF the agent path. Persist
    // these - never cost an agent call.
    _progressSubscription = _conversation.progressActions.listen((event) {
      switch (event.name) {
        case 'roadmapGenerated':
          add(
            _DiscoveryStepsGenerated(steps: _stepsFromContext(event.context)),
          );
        case 'roadmapStepToggled':
          add(
            _DiscoveryStepToggled(
              stepId: event.context['stepId'] as String? ?? '',
              isComplete: event.context['isComplete'] as bool? ?? false,
            ),
          );
      }
    });

    // 3) Raw streamed text from the agent. Only use text arrival
    // as a signal that the agent is responding (typing dots).
    _textSubscription = _conversation.incomingText.listen(
      (_) => add(const _DiscoveryAgentChunkReceived()),
    );

    // 4) Session pivot: the agent offered to start a new hobby session and
    // the user accepted. Same handling as the Home "start something new"
    // CTA — restart with the new hobby name as the seed.
    _pivotSubscription = _conversation.newSessionRequests.listen((event) {
      add(DiscoveryNewSessionRequested(seedInput: event.hobbyName));
    });
  }

  // Cancel only the conversation-derived subscriptions. Called before we swap
  // in a new conversation and in close(), so we don't leak listeners.
  Future<void> _cancelConversationSubscriptions() async {
    await _pivotSubscription.cancel();
    await _surfaceSubscription.cancel();
    await _progressSubscription.cancel();
    await _textSubscription.cancel();
  }

  /// Tears down the current conversation, starts a fresh one, and resets
  /// state to a clean session tied to [hobbyId] (null for a brand-new one).
  Future<void> _restartSession(
    Emitter<DiscoveryState> emit, {
    required String? hobbyId,
    Set<String> completedStepIds = const {},
  }) async {
    await _cancelConversationSubscriptions();
    _conversation.dispose();
    _conversation = _conversationFactory();
    _bindConversation();
    emit(DiscoveryState(hobbyId: hobbyId, completedStepIds: completedStepIds));
  }

  /// Starts a fresh discovery session, optionally seeding the first message.
  /// Triggered by the agent's "start a new session" pivot card and the Home
  // "start something new" CTA.
  Future<void> _onNewSessionRequested(
    DiscoveryNewSessionRequested event,
    Emitter<DiscoveryState> emit,
  ) async {
    await _restartSession(emit, hobbyId: null);
    final seed = event.seedInput?.trim();
    if (seed != null && seed.isNotEmpty) {
      // If we were handed a hobby name (example: "cooking" from a pivot),
      // put it in the input and submit it,
      // so the new session starts immediately.
      emit(state.copyWith(hobbyInput: seed));
      add(const DiscoverySubmitted());
    }
  }

  /// Opens (resumes) a saved hobby by starting a fresh conversation tied to
  /// it and reseeding the agent with its name and progress.
  Future<void> _onHobbyOpened(
    DiscoveryHobbyOpened event,
    Emitter<DiscoveryState> emit,
  ) async {
    final hobbies = await _hobbyRepository.watchHobbies().first;
    Hobby? hobby;
    for (final candidate in hobbies) {
      if (candidate.id == event.hobbyId) {
        hobby = candidate;
        break;
      }
    }
    if (hobby == null) return;

    // Clean session, but keep this hobby's id and its completed steps so the
    // regenerated roadmap shows the right check marks and saves to the same id.
    await _restartSession(
      emit,
      hobbyId: hobby.id,
      completedStepIds: {
        for (final step in hobby.steps)
          if (step.isComplete) step.id,
      },
    );
    // Reseed: we don't have the old transcript, so we tell the agent to
    // continue this hobby. This is one agent call per open.
    emit(state.copyWith(status: DiscoveryStatus.loading, isResponding: true));
    final progress =
        '${hobby.completedCount} of ${hobby.totalCount} steps done';
    try {
      await _conversation.sendRequest(
        'The user is resuming their "${hobby.name}" journey ($progress). '
        'Show the OnboardingRoadmap and help them continue.',
      );
      emit(state.copyWith(status: DiscoveryStatus.success));
    } catch (_) {
      emit(
        state.copyWith(status: DiscoveryStatus.failure, isResponding: false),
      );
    }
  }

  // Converts the raw roadmapGenerated payload into typed JourneyStep models.
  List<JourneyStep> _stepsFromContext(Map<String, dynamic> context) {
    final raw = (context['steps'] as List?) ?? const [];
    return raw.map((entry) {
      final map = (entry as Map).cast<String, dynamic>();
      return JourneyStep(
        id: map['id'] as String,
        title: map['title'] as String,
        category: (map['category'] as String? ?? 'gear').trim().toLowerCase(),
        dependsOn: ((map['dependsOn'] as List?) ?? const [])
            .map((e) => e as String)
            .toList(),
      );
    }).toList();
  }

  /// Mirrors the current hobby's completed step ids into state so the roadmap
  /// can display persisted progress.
  /// Fires whenever the repository changes. It keeps completedStepIds in state
  // in sync with the source of truth, which is how the roadmap's checks
  // survive scrolling and reflect completions made from other cards.
  void _onHobbiesUpdated(
    _DiscoveryHobbiesUpdated event,
    Emitter<DiscoveryState> emit,
  ) {
    final id = state.hobbyId;
    // no active hobby yet
    if (id == null) return;

    Hobby? hobby;
    // Find this session's hobby in the latest snapshot.
    for (final candidate in event.hobbies) {
      if (candidate.id == id) {
        hobby = candidate;
        break;
      }
    }
    if (hobby == null) return;
    // Recompute the set of completed step ids from the repository.
    emit(
      state.copyWith(
        completedStepIds: {
          for (final step in hobby.steps)
            if (step.isComplete) step.id,
        },
      ),
    );
  }

  // Persist the steps the roadmap just announced to the current hobby.
  Future<void> _onStepsGenerated(
    _DiscoveryStepsGenerated event,
    Emitter<DiscoveryState> emit,
  ) async {
    final hobbyId = state.hobbyId;
    if (hobbyId == null) return;
    await _hobbyRepository.setSteps(hobbyId: hobbyId, steps: event.steps);
  }

  // Persist a single step's completion (from the roadmap or a step's card).
  Future<void> _onStepToggled(
    _DiscoveryStepToggled event,
    Emitter<DiscoveryState> emit,
  ) async {
    final hobbyId = state.hobbyId;
    if (hobbyId == null) return;
    await _hobbyRepository.setStepComplete(
      hobbyId: hobbyId,
      stepId: event.stepId,
      isComplete: event.isComplete,
    );
  }

  /// Persists the hobby on the first message, then sends input to the agent.
  ///
  /// Guards against empty input and duplicate in-flight requests.
  Future<void> _onSubmitted(
    DiscoverySubmitted event,
    Emitter<DiscoveryState> emit,
  ) async {
    final message = state.hobbyInput.trim();
    if (message.isEmpty) return;
    if (state.status == DiscoveryStatus.loading) return;

    // First message of a session creates and saves the hobby record.
    var hobbyId = state.hobbyId;
    if (hobbyId == null) {
      hobbyId = _generateId();
      await _hobbyRepository.saveHobby(
        Hobby(id: hobbyId, name: message, createdAt: DateTime.now()),
      );
    }
    // Show the user's message immediately, clear the input, mark responding.
    emit(
      state.copyWith(
        status: DiscoveryStatus.loading,
        isResponding: true,
        hobbyInput: '',
        hobbyId: hobbyId,
        items: [...state.items, UserMessageItem(message)],
      ),
    );

    try {
      await _conversation.sendRequest(message);
      emit(state.copyWith(status: DiscoveryStatus.success));
    } catch (_) {
      emit(
        state.copyWith(status: DiscoveryStatus.failure, isResponding: false),
      );
    }
  }

  /// Flips [DiscoveryState.isResponding] on at the first streamed chunk.
  void _onAgentChunkReceived(
    _DiscoveryAgentChunkReceived event,
    Emitter<DiscoveryState> emit,
  ) {
    if (!state.isResponding) emit(state.copyWith(isResponding: true));
  }

  /// Appends a generated surface to the feed and clears the typing state.
  void _onSurfaceAdded(
    _DiscoverySurfaceAdded event,
    Emitter<DiscoveryState> emit,
  ) {
    emit(
      state.copyWith(
        items: [...state.items, AgentSurfaceItem(event.surfaceId)],
        isResponding: false,
      ),
    );
  }

  /// Removes a surface from the feed.
  void _onSurfaceRemoved(
    _DiscoverySurfaceRemoved event,
    Emitter<DiscoveryState> emit,
  ) {
    emit(
      state.copyWith(
        items: state.items
            .where(
              (item) =>
                  item is! AgentSurfaceItem ||
                  item.surfaceId != event.surfaceId,
            )
            .toList(),
      ),
    );
  }

  /// Fired when surfaces are updated.
  void _onSurfaceUpdated(
    _DiscoverySurfaceUpdated event,
    Emitter<DiscoveryState> emit,
  ) {
    emit(state.copyWith(surfaceRevision: state.surfaceRevision + 1));
  }

  @override
  Future<void> close() async {
    await _cancelConversationSubscriptions();
    await _hobbiesSubscription.cancel();
    _conversation.dispose();
    return super.close();
  }
}
