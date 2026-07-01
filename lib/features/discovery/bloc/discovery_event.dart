part of 'discovery_bloc.dart';

/// Base class for all onboarding-related events.
///
/// All events that drive the [DiscoveryBloc] must extend this class.
/// Uses sealed to enforce exhaustive handling in switch expressions.
sealed class DiscoveryEvent extends Equatable {
  const DiscoveryEvent();

  @override
  List<Object> get props => [];
}

/// Fired when the user updates the hobby input field.
///
/// Should be dispatched on every keystroke so [DiscoveryBloc]
/// keeps [DiscoveryState.hobbyInput] in sync with the text field.
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
/// generation. Has no effect if [DiscoveryState.hobbyInput] is empty.
final class DiscoverySubmitted extends DiscoveryEvent {
  /// Creates an [DiscoverySubmitted] event.
  const DiscoverySubmitted();
}

/// Fired internally when the GenUI pipeline adds a new surface.
///
/// Not dispatched by the UI — only by [DiscoveryBloc] in response
/// to [ConversationSurfaceAdded] events from [HobbyConversation].
final class _DiscoverySurfaceAdded extends DiscoveryEvent {
  const _DiscoverySurfaceAdded(this.surfaceId);

  /// The ID of the newly created surface.
  final String surfaceId;

  @override
  List<Object> get props => [surfaceId];
}

/// Fired internally when the GenUI pipeline removes a surface.
final class _DiscoverySurfaceRemoved extends DiscoveryEvent {
  const _DiscoverySurfaceRemoved(this.surfaceId);

  /// The ID of the surface to remove.
  final String surfaceId;

  @override
  List<Object> get props => [surfaceId];
}

/// Fired internally when the agent streams a chunk of its response.
///
/// Used by [DiscoveryBloc] to flip [DiscoveryState.isResponding] on so the
/// feed can show a typing indicator. Not dispatched by the UI.
final class _DiscoveryAgentChunkReceived extends DiscoveryEvent {
  const _DiscoveryAgentChunkReceived();
}
