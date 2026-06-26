import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:genui/genui.dart';
import 'package:hob_it/genui/hobby_conversation.dart';

part 'discovery_event.dart';
part 'discovery_state.dart';

/// Manages state for the Discovery flow.
///
/// Owns a [HobbyConversation] instance, forwards user input to it,
/// and translates GenUI surface events into [DiscoveryState] updates.
class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  /// Creates a [DiscoveryBloc] with the given [conversation].
  DiscoveryBloc({required HobbyConversation conversation})
    : _conversation = conversation,
      super(const DiscoveryState()) {
    on<DiscoveryHobbyInputChanged>(_onHobbyInputChanged);
    on<DiscoverySubmitted>(_onSubmitted);
    on<_DiscoverySurfaceAdded>(_onSurfaceAdded);
    on<_DiscoverySurfaceRemoved>(_onSurfaceRemoved);

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
  }

  final HobbyConversation _conversation;

  late final StreamSubscription<SurfaceUpdate> _conversationSubscription;

  /// Exposes the [HobbyConversation] so the view can pass [ConversationHost]
  /// to [Surface] widgets.
  HobbyConversation get conversation => _conversation;

  /// Updates [DiscoveryState.hobbyInput] as the user types.
  void _onHobbyInputChanged(
    DiscoveryHobbyInputChanged event,
    Emitter<DiscoveryState> emit,
  ) {
    emit(state.copyWith(hobbyInput: event.input));
  }

  /// Sends the hobby description to the Gemini agent.
  ///
  /// Guards against empty input and duplicate in-flight requests.
  Future<void> _onSubmitted(
    DiscoverySubmitted event,
    Emitter<DiscoveryState> emit,
  ) async {
    if (state.hobbyInput.isEmpty) return;
    if (state.status == DiscoveryStatus.loading) return;

    emit(state.copyWith(status: DiscoveryStatus.loading));

    try {
      _conversation.sendRequest(state.hobbyInput);
      emit(state.copyWith(status: DiscoveryStatus.success));
    } catch (e) {
      emit(state.copyWith(status: DiscoveryStatus.failure));
    }
  }

  /// Appends a newly created surface ID to [DiscoveryState.surfaceIds].
  void _onSurfaceAdded(
    _DiscoverySurfaceAdded event,
    Emitter<DiscoveryState> emit,
  ) {
    emit(state.copyWith(surfaceIds: [...state.surfaceIds, event.surfaceId]));
  }

  /// Removes a surface ID from [DiscoveryState.surfaceIds].
  void _onSurfaceRemoved(
    _DiscoverySurfaceRemoved event,
    Emitter<DiscoveryState> emit,
  ) {
    emit(
      state.copyWith(
        surfaceIds: state.surfaceIds
            .where((id) => id != event.surfaceId)
            .toList(),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _conversationSubscription.cancel();
    _conversation.dispose();
    return super.close();
  }
}
