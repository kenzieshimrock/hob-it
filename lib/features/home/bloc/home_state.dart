part of 'home_bloc.dart';

/// The phase of the home feed.
enum HomeStatus {
  /// Nothing generated yet.
  initial,

  /// The feed is being generated.
  loading,

  /// The feed generated successfully.
  ready,

  /// No hobbies yet, so nothing was generated.
  empty,

  /// Generation failed.
  failure,
}

/// State for the Home tab.
final class HomeState extends Equatable {
  /// Creates a [HomeState].
  const HomeState({
    this.status = HomeStatus.initial,
    this.surfaceIds = const [],
  });

  /// The current phase.
  final HomeStatus status;

  /// IDs of the generated home surfaces, in order.
  final List<String> surfaceIds;

  /// Returns a copy with the given fields replaced.
  HomeState copyWith({HomeStatus? status, List<String>? surfaceIds}) {
    return HomeState(
      status: status ?? this.status,
      surfaceIds: surfaceIds ?? this.surfaceIds,
    );
  }

  @override
  List<Object> get props => [status, surfaceIds];
}
