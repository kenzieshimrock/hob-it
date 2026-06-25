import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'discovery_event.dart';
part 'discovery_state.dart';

/// Manages the state of the onboarding flow.
///
/// Handles user hobby input and submission, coordinating
/// with the GenUI [Conversation] to generate the initial
/// surface based on the user's expressed hobby interest.
class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  /// Creates an [DiscoveryBloc] with an [DiscoveryState.initial] state.
  DiscoveryBloc() : super(const DiscoveryState()) {
    on<DiscoveryHobbyInputChanged>(_onHobbyInputChanged);
    on<DiscoverySubmitted>(_onSubmitted);
  }

  /// Updates [DiscoveryState.hobbyInput] as the user types.
  void _onHobbyInputChanged(
    DiscoveryHobbyInputChanged event,
    Emitter<DiscoveryState> emit,
  ) {
    emit(state.copyWith(hobbyInput: event.input));
  }

  /// Submits the hobby input and triggers the GenUI surface generation.
  ///
  /// Sets status to [DiscoveryStatus.loading] while the agent processes
  /// the request. On success, transitions to [DiscoveryStatus.success].
  /// On failure, transitions to [DiscoveryStatus.failure].
  Future<void> _onSubmitted(
    DiscoverySubmitted event,
    Emitter<DiscoveryState> emit,
  ) async {
    if (state.hobbyInput.isEmpty) return;

    emit(state.copyWith(status: DiscoveryStatus.loading));

    try {
      // TODO: wire Gemini Conversation call here
      emit(state.copyWith(status: DiscoveryStatus.success));
    } catch (e) {
      emit(state.copyWith(status: DiscoveryStatus.failure));
    }
  }
}
