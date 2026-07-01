// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journey_step.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JourneyStep _$JourneyStepFromJson(Map<String, dynamic> json) => JourneyStep(
  id: json['id'] as String,
  title: json['title'] as String,
  category: _normalizeCategory(json['category'] as String),
  isComplete: json['isComplete'] as bool? ?? false,
);

Map<String, dynamic> _$JourneyStepToJson(JourneyStep instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'category': instance.category,
      'isComplete': instance.isComplete,
    };
