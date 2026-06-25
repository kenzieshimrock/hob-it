part of 'discovery_bloc.dart';

/// Describes the current phase of an onboarding agent request.
enum DiscoveryStatus {
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
final class DiscoveryState extends Equatable {
  /// Creates an [DiscoveryState].
  ///
  /// Defaults to [DiscoveryStatus.initial] with an empty [hobbyInput].
  const DiscoveryState({
    this.status = DiscoveryStatus.initial,
    this.hobbyInput = '',
  });

  /// The current phase of the onboarding agent request.
  final DiscoveryStatus status;

  /// The hobby description entered by the user.
  ///
  /// This value is sent to the Gemini agent on [DiscoverySubmitted].
  final String hobbyInput;

  /// Returns a copy of this state with the given fields replaced.
  DiscoveryState copyWith({DiscoveryStatus? status, String? hobbyInput}) {
    return DiscoveryState(
      status: status ?? this.status,
      hobbyInput: hobbyInput ?? this.hobbyInput,
    );
  }

  @override
  List<Object> get props => [status, hobbyInput];
}
