// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProjectImpl _$$ProjectImplFromJson(Map<String, dynamic> json) =>
    _$ProjectImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      supabaseUrl: json['supabaseUrl'] as String,
      anonKey: json['anonKey'] as String,
      serviceRoleKey: json['serviceRoleKey'] as String?,
      color: json['color'] as String? ?? '',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ProjectImplToJson(_$ProjectImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'supabaseUrl': instance.supabaseUrl,
      'anonKey': instance.anonKey,
      'serviceRoleKey': instance.serviceRoleKey,
      'color': instance.color,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
