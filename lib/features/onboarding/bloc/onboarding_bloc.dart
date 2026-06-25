import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

/// Manages the state of the onboarding flow.
///
/// Handles user hobby input and submission, coordinating
/// with the GenUI [Conversation] to generate the initial
/// surface based on the user's expressed hobby interest.
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  /// Creates an [OnboardingBloc] with an [OnboardingState.initial] state.
  OnboardingBloc() : super(const OnboardingState()) {
    on<OnboardingHobbyInputChanged>(_onHobbyInputChanged);
    on<OnboardingSubmitted>(_onSubmitted);
  }

  /// Updates [OnboardingState.hobbyInput] as the user types.
  void _onHobbyInputChanged(
    OnboardingHobbyInputChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(hobbyInput: event.input));
  }

  /// Submits the hobby input and triggers the GenUI surface generation.
  ///
  /// Sets status to [OnboardingStatus.loading] while the agent processes
  /// the request. On success, transitions to [OnboardingStatus.success].
  /// On failure, transitions to [OnboardingStatus.failure].
  Future<void> _onSubmitted(
    OnboardingSubmitted event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state.hobbyInput.isEmpty) return;

    emit(state.copyWith(status: OnboardingStatus.loading));

    try {
      // TODO: wire Gemini Conversation call here
      emit(state.copyWith(status: OnboardingStatus.success));
    } catch (e) {
      emit(state.copyWith(status: OnboardingStatus.failure));
    }
  }
}
