import 'dart:async';

import 'package:hobby_api/hobby_api.dart';

/// {@template in_memory_hobby_api}
/// An in-memory [HobbyApi] storing raw JSON maps. State is lost on restart.
/// {@endtemplate}
class InMemoryHobbyApi implements HobbyApi {
  /// {@macro in_memory_hobby_api}
  InMemoryHobbyApi();

  final Map<String, Map<String, dynamic>> _hobbies = {};
  final StreamController<List<Map<String, dynamic>>> _controller =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  List<Map<String, dynamic>> get _snapshot => _hobbies.values.toList();

  @override
  Stream<List<Map<String, dynamic>>> getHobbies() async* {
    yield _snapshot;
    yield* _controller.stream;
  }

  @override
  Future<void> saveHobby(Map<String, dynamic> hobby) async {
    _hobbies[hobby['id'] as String] = hobby;
    _controller.add(_snapshot);
  }

  @override
  Future<void> deleteHobby(String id) async {
    if (!_hobbies.containsKey(id)) {
      throw HobbyNotFoundException();
    }
    _hobbies.remove(id);
    _controller.add(_snapshot);
  }

  @override
  Future<void> close() => _controller.close();
}
