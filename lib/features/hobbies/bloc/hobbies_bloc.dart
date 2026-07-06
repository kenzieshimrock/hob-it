import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hobby_repository/hobby_repository.dart';

part 'hobbies_event.dart';
part 'hobbies_state.dart';

/// Watches the [HobbyRepository] and exposes the hobby list to the UI.
class HobbiesBloc extends Bloc<HobbiesEvent, HobbiesState> {
  /// Creates a [HobbiesBloc].
  HobbiesBloc({required HobbyRepository hobbyRepository})
    : _hobbyRepository = hobbyRepository,
      super(const HobbiesState()) {
    on<HobbiesSubscriptionRequested>(_onSubscriptionRequested);
  }

  final HobbyRepository _hobbyRepository;

  /// Subscribes to the repository stream and emits a new state per update.
  Future<void> _onSubscriptionRequested(
    HobbiesSubscriptionRequested event,
    Emitter<HobbiesState> emit,
  ) {
    emit(state.copyWith(status: HobbiesStatus.loading));

    /// keeps the subscription alive for the life of the
    /// bloc and cancels it automatically on close.
    return emit.forEach<List<Hobby>>(
      _hobbyRepository.watchHobbies(),
      onData: (hobbies) =>
          state.copyWith(status: HobbiesStatus.success, hobbies: hobbies),
      onError: (_, _) => state.copyWith(status: HobbiesStatus.failure),
    );
  }
}
