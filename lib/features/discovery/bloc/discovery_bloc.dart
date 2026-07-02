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
  DiscoveryBloc({required this._conversation, required this._hobbyRepository})
    : super(const DiscoveryState()) {
    on<DiscoveryHobbyInputChanged>(_onHobbyInputChanged);
    on<DiscoverySubmitted>(_onSubmitted);
    on<_DiscoverySurfaceAdded>(_onSurfaceAdded);
    on<_DiscoverySurfaceRemoved>(_onSurfaceRemoved);
    on<_DiscoveryAgentChunkReceived>(_onAgentChunkReceived);
    on<_DiscoveryStepsGenerated>(_onStepsGenerated);
    on<_DiscoveryStepToggled>(_onStepToggled);
    // in the constructor, alongside the other subscriptions:
    on<_DiscoveryHobbiesUpdated>(_onHobbiesUpdated);

    _hobbiesSubscription = _hobbyRepository.watchHobbies().listen(
      (hobbies) => add(_DiscoveryHobbiesUpdated(hobbies)),
    );

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

    _conversationSubscription = _conversation.surfaceUpdates.listen((update) {
      switch (update) {
        case SurfaceAdded(:final surfaceId):
          add(_DiscoverySurfaceAdded(surfaceId));
        case SurfaceRemoved(:final surfaceId):
          add(_DiscoverySurfaceRemoved(surfaceId));
        case ComponentsUpdated():
          break;
      }
    });

    _textSubscription = _conversation.incomingText.listen(
      (_) => add(const _DiscoveryAgentChunkReceived()),
    );
  }

  final HobbyConversation _conversation;
  final HobbyRepository _hobbyRepository;

  late final StreamSubscription<List<Hobby>> _hobbiesSubscription;
  late final StreamSubscription<SurfaceUpdate> _conversationSubscription;
  late final StreamSubscription<String> _textSubscription;
  late final StreamSubscription<SurfaceProgressEvent> _progressSubscription;

  /// Exposes the [HobbyConversation] so the view can pass its host to
  /// [Surface] widgets.
  HobbyConversation get conversation => _conversation;

  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();

  /// Updates [DiscoveryState.hobbyInput] as the user types.
  void _onHobbyInputChanged(
    DiscoveryHobbyInputChanged event,
    Emitter<DiscoveryState> emit,
  ) {
    emit(state.copyWith(hobbyInput: event.input));
  }

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
  void _onHobbiesUpdated(
    _DiscoveryHobbiesUpdated event,
    Emitter<DiscoveryState> emit,
  ) {
    final id = state.hobbyId;
    if (id == null) return;

    Hobby? hobby;
    for (final candidate in event.hobbies) {
      if (candidate.id == id) {
        hobby = candidate;
        break;
      }
    }
    if (hobby == null) return;

    emit(
      state.copyWith(
        completedStepIds: {
          for (final step in hobby.steps)
            if (step.isComplete) step.id,
        },
      ),
    );
  }

  Future<void> _onStepsGenerated(
    _DiscoveryStepsGenerated event,
    Emitter<DiscoveryState> emit,
  ) async {
    final hobbyId = state.hobbyId;
    if (hobbyId == null) return;
    await _hobbyRepository.setSteps(hobbyId: hobbyId, steps: event.steps);
  }

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

    // The first message of the session starts a new persisted hobby.
    var hobbyId = state.hobbyId;
    if (hobbyId == null) {
      hobbyId = _generateId();
      await _hobbyRepository.saveHobby(
        Hobby(id: hobbyId, name: message, createdAt: DateTime.now()),
      );
    }

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
      _conversation.sendRequest(message);
      emit(state.copyWith(status: DiscoveryStatus.success));
    } catch (e) {
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

  @override
  Future<void> close() async {
    await _conversationSubscription.cancel();
    await _textSubscription.cancel();
    await _progressSubscription.cancel();
    await _hobbiesSubscription.cancel();
    _conversation.dispose();
    return super.close();
  }
}
