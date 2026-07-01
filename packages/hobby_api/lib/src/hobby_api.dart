/// Thrown when a requested hobby does not exist.
class HobbyNotFoundException implements Exception {}

/// The contract for a raw hobby data source.
///
/// Deals in JSON maps only. It holds no domain models and no domain rules,
/// so it can be backed by any store (in memory, Firestore) and reused.
abstract interface class HobbyApi {
  /// Streams the raw hobby records, re-emitting on every change.
  Stream<List<Map<String, dynamic>>> getHobbies();

  /// Inserts or replaces the record, keyed by its `id` field.
  Future<void> saveHobby(Map<String, dynamic> hobby);

  /// Deletes the record with [id].
  ///
  /// Throws [HobbyNotFoundException] if no matching record exists.
  Future<void> deleteHobby(String id);

  /// Closes the source and releases resources.
  Future<void> close();
}
