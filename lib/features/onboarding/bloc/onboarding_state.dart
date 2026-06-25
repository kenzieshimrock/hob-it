part of 'onboarding_bloc.dart';

/// Describes the current phase of an onboarding agent request.
enum OnboardingStatus {
  /// No request has been made yet.
  initial,

  /// A request is in flight.
  loading,

  /// The agent responded successfully and a surface has been generated.
  success,

  /// The agent request failed.
  failure,
}

/// Represents the state of the onboarding flow.
///
/// Immutable. All state transitions are produced via [copyWith].
final class OnboardingState extends Equatable {
  /// Creates an [OnboardingState].
  ///
  /// Defaults to [OnboardingStatus.initial] with an empty [hobbyInput].
  const OnboardingState({
    this.status = OnboardingStatus.initial,
    this.hobbyInput = '',
  });

  /// The current phase of the onboarding agent request.
  final OnboardingStatus status;

  /// The hobby description entered by the user.
  ///
  /// This value is sent to the Gemini agent on [OnboardingSubmitted].
  final String hobbyInput;

  /// Returns a copy of this state with the given fields replaced.
  OnboardingState copyWith({OnboardingStatus? status, String? hobbyInput}) {
    return OnboardingState(
      status: status ?? this.status,
      hobbyInput: hobbyInput ?? this.hobbyInput,
    );
  }

  @override
  List<Object> get props => [status, hobbyInput];
}
