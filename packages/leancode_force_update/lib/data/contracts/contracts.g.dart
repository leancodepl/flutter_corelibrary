// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contracts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VersionSupport _$VersionSupportFromJson(Map<String, dynamic> json) =>
    VersionSupport(
      platform: $enumDecode(_$PlatformDTOEnumMap, json['Platform']),
      version: json['Version'] as String,
    );

Map<String, dynamic> _$VersionSupportToJson(VersionSupport instance) =>
    <String, dynamic>{
      'Platform': _$PlatformDTOEnumMap[instance.platform]!,
      'Version': instance.version,
    };

const _$PlatformDTOEnumMap = {PlatformDTO.android: 0, PlatformDTO.ios: 1};

VersionSupportDTO _$VersionSupportDTOFromJson(Map<String, dynamic> json) =>
    VersionSupportDTO(
      currentlySupportedVersion: json['CurrentlySupportedVersion'] as String,
      minimumRequiredVersion: json['MinimumRequiredVersion'] as String,
      result: $enumDecode(_$VersionSupportResultDTOEnumMap, json['Result']),
    );

Map<String, dynamic> _$VersionSupportDTOToJson(VersionSupportDTO instance) =>
    <String, dynamic>{
      'CurrentlySupportedVersion': instance.currentlySupportedVersion,
      'MinimumRequiredVersion': instance.minimumRequiredVersion,
      'Result': _$VersionSupportResultDTOEnumMap[instance.result]!,
    };

const _$VersionSupportResultDTOEnumMap = {
  VersionSupportResultDTO.updateRequired: 0,
  VersionSupportResultDTO.updateSuggested: 1,
  VersionSupportResultDTO.upToDate: 2,
};

Class1 _$Class1FromJson(Map<String, dynamic> json) => Class1();

Map<String, dynamic> _$Class1ToJson(Class1 instance) => <String, dynamic>{};
