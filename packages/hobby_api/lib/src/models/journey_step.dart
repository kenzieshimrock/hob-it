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
  });

  /// Creates a [JourneyStep] from a JSON map.
  factory JourneyStep.fromJson(Map<String, dynamic> json) =>
      _$JourneyStepFromJson(json);

  /// Stable identifier for the step within its hobby, e.g. "1".
  final String id;

  /// The step headline, e.g. "Join a climbing gym".
  final String title;

  /// A short lowercase category keyword, e.g. "gear" or a novel one the
  /// agent chose such as "safety". Normalized (trimmed, lowercase) on decode.
  @JsonKey(fromJson: _normalizeCategory)
  final String category;

  /// Whether the user has completed this step.
  final bool isComplete;

  /// Returns a copy with the given fields replaced.
  JourneyStep copyWith({
    String? id,
    String? title,
    String? category,
    bool? isComplete,
  }) {
    return JourneyStep(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  /// Converts this step to a JSON map.
  Map<String, dynamic> toJson() => _$JourneyStepToJson(this);

  @override
  List<Object?> get props => [id, title, category, isComplete];
}
