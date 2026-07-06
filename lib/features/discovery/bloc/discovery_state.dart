part of 'discovery_bloc.dart';

/// A single entry in the discovery conversation feed.
///
/// Sealed so the view can switch exhaustively over user messages and
/// agent-generated surfaces.
sealed class DiscoveryFeedItem extends Equatable {
  const DiscoveryFeedItem();
}

/// A message the user typed or selected, shown as a right-aligned bubble.
final class UserMessageItem extends DiscoveryFeedItem {
  /// Creates a [UserMessageItem].
  const UserMessageItem(this.text);

  /// The message text the user sent.
  final String text;

  @override
  List<Object> get props => [text];
}

/// A generated agent surface, referenced by its GenUI surface ID.
final class AgentSurfaceItem extends DiscoveryFeedItem {
  /// Creates an [AgentSurfaceItem].
  const AgentSurfaceItem(this.surfaceId);

  /// The ID of the surface to render via the [SurfaceHost].
  final String surfaceId;

  @override
  List<Object> get props => [surfaceId];
}

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
    this.items = const [],
    this.isResponding = false,
    this.hobbyId,
    this.completedStepIds = const {},
    this.surfaceRevision = 0,
  });

  /// Whether the agent is currently streaming a response.
  ///
  /// Drives the typing indicator in the feed. Set true when the agent
  /// starts streaming, and false once its next surface has rendered.
  final bool isResponding;

  /// The current phase of the onboarding agent request.
  final DiscoveryStatus status;

  /// The hobby description entered by the user.
  ///
  /// This value is sent to the Gemini agent on [DiscoverySubmitted].
  final String hobbyInput;

  /// The list of items in the Discovery feed.
  final List<DiscoveryFeedItem> items;

  /// The id of the hobby this discovery session is building, or null before
  /// the first message is sent.
  final String? hobbyId;

  /// Ids of the current hobby's completed steps, mirrored from the repository.
  final Set<String> completedStepIds;

  /// Increments whenever a surface's components change, so the feed can keep
  /// scrolling as a surface streams in.
  final int surfaceRevision;

  /// Returns a copy of this state with the given fields replaced.
  DiscoveryState copyWith({
    DiscoveryStatus? status,
    String? hobbyInput,
    List<DiscoveryFeedItem>? items,
    bool? isResponding,
    String? hobbyId,
    Set<String>? completedStepIds,
    int? surfaceRevision,
  }) {
    return DiscoveryState(
      status: status ?? this.status,
      hobbyInput: hobbyInput ?? this.hobbyInput,
      items: items ?? this.items,
      isResponding: isResponding ?? this.isResponding,
      hobbyId: hobbyId ?? this.hobbyId,
      completedStepIds: completedStepIds ?? this.completedStepIds,
      surfaceRevision: surfaceRevision ?? this.surfaceRevision,
    );
  }

  @override
  List<Object?> get props => [
    status,
    hobbyInput,
    items,
    isResponding,
    hobbyId,
    completedStepIds,
    surfaceRevision,
  ];
}
