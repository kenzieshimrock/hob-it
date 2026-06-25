part of 'onboarding_bloc.dart';

/// Base class for all onboarding-related events.
///
/// All events that drive the [OnboardingBloc] must extend this class.
/// Uses [sealed] to enforce exhaustive handling in switch expressions.
sealed class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object> get props => [];
}

/// Fired when the user updates the hobby input field.
///
/// Should be dispatched on every keystroke so [OnboardingBloc]
/// keeps [OnboardingState.hobbyInput] in sync with the text field.
///
/// Example:
/// ```dart
/// context.read<OnboardingBloc>().add(
///   const OnboardingHobbyInputChanged('fly fishing'),
/// );
/// ```
final class OnboardingHobbyInputChanged extends OnboardingEvent {
  /// Creates an [OnboardingHobbyInputChanged] with the given [input].
  const OnboardingHobbyInputChanged(this.input);

  /// The current value of the hobby text field.
  final String input;

  @override
  List<Object> get props => [input];
}

/// Fired when the user submits their hobby selection.
///
/// Triggers the Gemini agent call and initiates GenUI surface
/// generation. Has no effect if [OnboardingState.hobbyInput] is empty.
final class OnboardingSubmitted extends OnboardingEvent {
  /// Creates an [OnboardingSubmitted] event.
  const OnboardingSubmitted();
}
