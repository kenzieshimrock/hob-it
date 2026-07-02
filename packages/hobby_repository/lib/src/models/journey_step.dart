import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'journey_step.g.dart';

String _normalizeCategory(String value) => value.trim().toLowerCase();

/// {@template journey_step}
/// One step in a hobby's onboarding journey, with its completion state.
/// {@endtemplate}
@JsonSerializable()
class JourneyStep extends Equatable {
  /// {@macro journey_step}
  const JourneyStep({
    required this.id,
    required this.title,
    required this.category,
    this.isComplete = false,
    this.dependsOn = const [],
  });

  /// Creates a [JourneyStep] from a JSON map.
  factory JourneyStep.fromJson(Map<String, dynamic> json) =>
      _$JourneyStepFromJson(json);

  /// Stable id within the roadmap (the step order as a string).
  final String id;

  /// The step headline.
  final String title;

  /// A short lowercase category keyword. Normalized on decode.
  @JsonKey(fromJson: _normalizeCategory)
  final String category;

  /// Whether the user has completed this step.
  final bool isComplete;

  /// Ids of steps that must be complete before this one is available.
  ///
  /// Empty for steps that can be done at any time.
  @JsonKey(defaultValue: <String>[])
  final List<String> dependsOn;

  /// Returns a copy with the given fields replaced.
  JourneyStep copyWith({
    String? id,
    String? title,
    String? category,
    bool? isComplete,
    List<String>? dependsOn,
  }) {
    return JourneyStep(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      isComplete: isComplete ?? this.isComplete,
      dependsOn: dependsOn ?? this.dependsOn,
    );
  }

  /// Converts this step to a JSON map.
  Map<String, dynamic> toJson() => _$JourneyStepToJson(this);

  @override
  List<Object?> get props => [id, title, category, isComplete, dependsOn];
}
