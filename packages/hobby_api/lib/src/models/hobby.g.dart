// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hobby.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Hobby _$HobbyFromJson(Map<String, dynamic> json) => Hobby(
  id: json['id'] as String,
  name: json['name'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  steps:
      (json['steps'] as List<dynamic>?)
          ?.map((e) => JourneyStep.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$HobbyToJson(Hobby instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'steps': instance.steps.map((e) => e.toJson()).toList(),
};
