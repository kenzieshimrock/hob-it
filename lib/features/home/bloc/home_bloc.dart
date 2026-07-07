import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:genui/genui.dart';
import 'package:hob_it/genui/home_conversation.dart';
import 'package:hobby_repository/hobby_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

/// Drives the memory-driven home feed.
///
/// Reads the user's hobbies from [HobbyRepository], summarizes them into
/// memory, and asks [HomeConversation] to generate the feed lazily: once per
/// session, and only when there are hobbies. Skips generation entirely for a
/// new user (empty state), which protects the agent's rate limit.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  /// Creates a [HomeBloc].
  HomeBloc({
    required HomeConversation homeConversation,
    required HobbyRepository hobbyRepository,
  }) : _homeConversation = homeConversation,
       _hobbyRepository = hobbyRepository,
       super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshRequested>(_onRefreshRequested);
    on<_HomeSurfaceAdded>(_onSurfaceAdded);
    on<_HomeSurfaceRemoved>(_onSurfaceRemoved);

    _surfaceSubscription = _homeConversation.surfaceUpdates.listen((update) {
      switch (update) {
        case SurfaceAdded(:final surfaceId):
          add(_HomeSurfaceAdded(surfaceId));
        case SurfaceRemoved(:final surfaceId):
          add(_HomeSurfaceRemoved(surfaceId));
        case ComponentsUpdated():
          break;
      }
    });
  }

  final HomeConversation _homeConversation;
  final HobbyRepository _hobbyRepository;

  late final StreamSubscription<SurfaceUpdate> _surfaceSubscription;
  bool _generated = false;

  /// Exposes the [HomeConversation] so the view can render surfaces and the
  /// shell can listen to its navigation actions.
  HomeConversation get conversation => _homeConversation;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    if (_generated) return; // Lazy: generate at most once per session.
    await _generate(emit);
  }

  Future<void> _onRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    _generated = false;
    emit(state.copyWith(surfaceIds: const []));
    await _generate(emit);
  }

  Future<void> _generate(Emitter<HomeState> emit) async {
    final hobbies = await _hobbyRepository.watchHobbies().first;
    if (hobbies.isEmpty) {
      emit(state.copyWith(status: HomeStatus.empty));
      return;
    }

    _generated = true;
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      await _homeConversation.generateFeed(_summarize(hobbies));
      emit(state.copyWith(status: HomeStatus.ready));
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.failure));
    }
  }

  String _summarize(List<Hobby> hobbies) {
    final lines = hobbies
        .map((hobby) {
          final progress = hobby.totalCount == 0
              ? 'not started'
              : '${hobby.completedCount} of ${hobby.totalCount} steps done';
          return '- ${hobby.name}: $progress';
        })
        .join('\n');
    return 'The user has explored these hobbies:\n$lines';
  }

  void _onSurfaceAdded(_HomeSurfaceAdded event, Emitter<HomeState> emit) {
    emit(state.copyWith(surfaceIds: [...state.surfaceIds, event.surfaceId]));
  }

  void _onSurfaceRemoved(_HomeSurfaceRemoved event, Emitter<HomeState> emit) {
    emit(
      state.copyWith(
        surfaceIds: state.surfaceIds
            .where((id) => id != event.surfaceId)
            .toList(),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _surfaceSubscription.cancel();
    _homeConversation.dispose();
    return super.close();
  }
}
