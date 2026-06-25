part of 'discovery_bloc.dart';

/// Base class for all onboarding-related events.
///
/// All events that drive the [DiscoveryBloc] must extend this class.
/// Uses [sealed] to enforce exhaustive handling in switch expressions.
sealed class DiscoveryEvent extends Equatable {
  const DiscoveryEvent();

  @override
  List<Object> get props => [];
}

/// Fired when the user updates the hobby input field.
///
/// Should be dispatched on every keystroke so [DiscoveryBloc]
/// keeps [OnboardingState.hobbyInput] in sync with the text field.
///
/// Example:
/// ```dart
/// context.read<DiscoveryBloc>().add(
///   const DiscoveryHobbyInputChanged('fly fishing'),
/// );
/// ```
final class DiscoveryHobbyInputChanged extends DiscoveryEvent {
  /// Creates an [DiscoveryHobbyInputChanged] with the given [input].
  const DiscoveryHobbyInputChanged(this.input);

  /// The current value of the hobby text field.
  final String input;

  @override
  List<Object> get props => [input];
}

/// Fired when the user submits their hobby selection.
///
/// Triggers the Gemini agent call and initiates GenUI surface
/// generation. Has no effect if [OnboardingState.hobbyInput] is empty.
final class DiscoverySubmitted extends DiscoveryEvent {
  /// Creates an [DiscoverySubmitted] event.
  const DiscoverySubmitted();
}
