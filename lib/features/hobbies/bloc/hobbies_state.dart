part of 'hobbies_bloc.dart';

/// The load phase of the hobbies list.
enum HobbiesStatus {
  /// Nothing requested yet.
  initial,

  /// The first load is in flight.
  loading,

  /// Hobbies are available (possibly an empty list).
  success,

  /// The stream errored.
  failure,
}

/// State for the Hobbies tab.
final class HobbiesState extends Equatable {
  /// Creates a [HobbiesState].
  const HobbiesState({
    this.status = HobbiesStatus.initial,
    this.hobbies = const [],
  });

  /// The current load phase.
  final HobbiesStatus status;

  /// The user's hobbies, most recently updated first.
  final List<Hobby> hobbies;

  /// Returns a copy with the given fields replaced.
  HobbiesState copyWith({HobbiesStatus? status, List<Hobby>? hobbies}) {
    return HobbiesState(
      status: status ?? this.status,
      hobbies: hobbies ?? this.hobbies,
    );
  }

  @override
  List<Object> get props => [status, hobbies];
}
