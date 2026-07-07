part of 'home_bloc.dart';

/// Base class for Home tab events.
sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

/// Fired once when the Home tab is first shown. Generates the feed lazily.
final class HomeStarted extends HomeEvent {
  /// Creates a [HomeStarted].
  const HomeStarted();
}

/// Fired when the user asks to refresh the feed.
final class HomeRefreshRequested extends HomeEvent {
  /// Creates a [HomeRefreshRequested].
  const HomeRefreshRequested();
}

/// Fired internally when the home pipeline adds a surface.
final class _HomeSurfaceAdded extends HomeEvent {
  const _HomeSurfaceAdded(this.surfaceId);

  final String surfaceId;

  @override
  List<Object> get props => [surfaceId];
}

/// Fired internally when the home pipeline removes a surface.
final class _HomeSurfaceRemoved extends HomeEvent {
  const _HomeSurfaceRemoved(this.surfaceId);

  final String surfaceId;

  @override
  List<Object> get props => [surfaceId];
}
