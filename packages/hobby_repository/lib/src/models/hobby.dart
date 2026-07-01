import 'package:equatable/equatable.dart';
import 'package:hobby_repository/src/models/journey_step.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hobby.g.dart';

/// {@template hobby}
/// A hobby the user is exploring, plus its onboarding progress.
/// {@endtemplate}
@JsonSerializable(explicitToJson: true)
class Hobby extends Equatable {
  /// {@macro hobby}
  const Hobby({
    required this.id,
    required this.name,
    required this.createdAt,
    this.steps = const [],
    this.updatedAt,
  });

  /// Creates a [Hobby] from a JSON map.
  factory Hobby.fromJson(Map<String, dynamic> json) => _$HobbyFromJson(json);

  /// Stable unique identifier for this hobby.
  final String id;

  /// Display name, e.g. "Rock climbing".
  final String name;

  /// When the hobby was first started.
  final DateTime createdAt;

  /// When the hobby was last changed, if ever.
  final DateTime? updatedAt;

  /// The onboarding steps and their completion state.
  @JsonKey(defaultValue: <JourneyStep>[])
  final List<JourneyStep> steps;

  /// The number of completed steps.
  @JsonKey(includeFromJson: false, includeToJson: false)
  int get completedCount => steps.where((step) => step.isComplete).length;

  /// The total number of steps.
  @JsonKey(includeFromJson: false, includeToJson: false)
  int get totalCount => steps.length;

  /// Completion fraction from 0.0 to 1.0; 0.0 when there are no steps.
  @JsonKey(includeFromJson: false, includeToJson: false)
  double get progress => steps.isEmpty ? 0 : completedCount / totalCount;

  /// Returns a copy with the given fields replaced.
  Hobby copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<JourneyStep>? steps,
  }) {
    return Hobby(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      steps: steps ?? this.steps,
    );
  }

  /// Converts this hobby to a JSON map.
  Map<String, dynamic> toJson() => _$HobbyToJson(this);

  @override
  List<Object?> get props => [id, name, createdAt, updatedAt, steps];
}
