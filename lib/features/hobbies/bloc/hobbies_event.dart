part of 'hobbies_bloc.dart';

/// Base class for Hobbies tab events.
sealed class HobbiesEvent extends Equatable {
  const HobbiesEvent();

  @override
  List<Object> get props => [];
}

/// Fired once to start watching the repository for hobby changes.
final class HobbiesSubscriptionRequested extends HobbiesEvent {
  /// Creates a [HobbiesSubscriptionRequested].
  const HobbiesSubscriptionRequested();
}
