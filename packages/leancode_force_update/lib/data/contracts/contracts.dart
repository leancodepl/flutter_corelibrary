// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
import 'package:leancode_contracts/leancode_contracts.dart';
part 'contracts.g.dart';

enum PlatformDTO {
  @JsonValue(0)
  android,
  @JsonValue(1)
  ios,
}

@ContractsSerializable()
class VersionSupport with EquatableMixin implements Query<VersionSupportDTO> {
  VersionSupport({required this.platform, required this.version});

  factory VersionSupport.fromJson(Map<String, dynamic> json) =>
      _$VersionSupportFromJson(json);

  final PlatformDTO platform;

  final String version;

  List<Object?> get props => [platform, version];

  Map<String, dynamic> toJson() => _$VersionSupportToJson(this);
  VersionSupportDTO resultFactory(dynamic decodedJson) =>
      _$VersionSupportDTOFromJson(decodedJson as Map<String, dynamic>);
  String getFullName() => 'LeanCode.ForceUpdate.Contracts.VersionSupport';
}

@ContractsSerializable()
class VersionSupportDTO with EquatableMixin {
  VersionSupportDTO({
    required this.currentlySupportedVersion,
    required this.minimumRequiredVersion,
    required this.result,
  });

  factory VersionSupportDTO.fromJson(Map<String, dynamic> json) =>
      _$VersionSupportDTOFromJson(json);

  final String currentlySupportedVersion;

  final String minimumRequiredVersion;

  final VersionSupportResultDTO result;

  List<Object?> get props => [
    currentlySupportedVersion,
    minimumRequiredVersion,
    result,
  ];

  Map<String, dynamic> toJson() => _$VersionSupportDTOToJson(this);
}

enum VersionSupportResultDTO {
  @JsonValue(0)
  updateRequired,
  @JsonValue(1)
  updateSuggested,
  @JsonValue(2)
  upToDate,
}

@ContractsSerializable()
class Class1 with EquatableMixin {
  Class1();

  factory Class1.fromJson(Map<String, dynamic> json) => _$Class1FromJson(json);

  List<Object?> get props => [];

  Map<String, dynamic> toJson() => _$Class1ToJson(this);
}
