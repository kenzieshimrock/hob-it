import 'package:hobby_api/hobby_api.dart';
import 'package:hobby_repository/src/models/models.dart';

/// {@template hobby_repository}
/// The single source of truth for hobbies and their onboarding progress.
///
/// Owns the domain models, composes a [HobbyApi] raw data source, maps
/// between raw JSON and models, and applies domain rules.
/// {@endtemplate}
class HobbyRepository {
  /// {@macro hobby_repository}
  const HobbyRepository({required HobbyApi hobbyApi}) : _hobbyApi = hobbyApi;

  final HobbyApi _hobbyApi;

  /// Streams hobbies as domain models, most recently updated first.
  Stream<List<Hobby>> watchHobbies() {
    return _hobbyApi.getHobbies().map((rows) {
      return rows.map(Hobby.fromJson).toList()..sort(
        (a, b) =>
            (b.updatedAt ?? b.createdAt).compareTo(a.updatedAt ?? a.createdAt),
      );
    });
  }

  /// Inserts or replaces [hobby].
  Future<void> saveHobby(Hobby hobby) => _hobbyApi.saveHobby(hobby.toJson());

  /// Deletes the hobby with [id].
  Future<void> deleteHobby(String id) => _hobbyApi.deleteHobby(id);

  /// Sets the completion state of step [stepId] within hobby [hobbyId].
  ///
  /// Reads the record, maps it to a model, updates the one step, and writes
  /// it back. Does nothing if the hobby or step is not found.
  Future<void> setStepComplete({
    required String hobbyId,
    required String stepId,
    required bool isComplete,
  }) async {
    final rows = await _hobbyApi.getHobbies().first;

    Map<String, dynamic>? row;
    for (final candidate in rows) {
      if (candidate['id'] == hobbyId) {
        row = candidate;
        break;
      }
    }
    if (row == null) return;

    final hobby = Hobby.fromJson(row);
    final steps = hobby.steps
        .map(
          (step) =>
              step.id == stepId ? step.copyWith(isComplete: isComplete) : step,
        )
        .toList();

    await _hobbyApi.saveHobby(
      hobby.copyWith(steps: steps, updatedAt: DateTime.now()).toJson(),
    );
  }

  /// Replaces the steps of hobby [hobbyId]. No-op if the hobby is not found.
  Future<void> setSteps({
    required String hobbyId,
    required List<JourneyStep> steps,
  }) async {
    final rows = await _hobbyApi.getHobbies().first;

    Map<String, dynamic>? row;
    for (final candidate in rows) {
      if (candidate['id'] == hobbyId) {
        row = candidate;
        break;
      }
    }
    if (row == null) return;

    final hobby = Hobby.fromJson(row);

    // No structural change (same ids/titles/categories/prerequisites) means a
    // re-announcement, e.g. after scrolling. Skip to preserve updatedAt and
    // avoid a redundant write.
    if (_sameStructure(hobby.steps, steps)) return;

    final done = {
      for (final step in hobby.steps)
        if (step.isComplete) step.id,
    };
    final merged = [
      for (final step in steps)
        done.contains(step.id) ? step.copyWith(isComplete: true) : step,
    ];

    await _hobbyApi.saveHobby(
      hobby.copyWith(steps: merged, updatedAt: DateTime.now()).toJson(),
    );
  }

  bool _sameStructure(List<JourneyStep> a, List<JourneyStep> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      // Compare everything except completion.
      if (a[i].copyWith(isComplete: false) !=
          b[i].copyWith(isComplete: false)) {
        return false;
      }
    }
    return true;
  }

  /// A short natural-language summary of the user's hobbies and progress,
  /// used to seed the home feed prompt.
  String memorySummary(List<Hobby> hobbies) {
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
}
