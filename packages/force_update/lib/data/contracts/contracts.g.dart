// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contracts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Auth _$AuthFromJson(Map<String, dynamic> json) => Auth();

Map<String, dynamic> _$AuthToJson(Auth instance) => <String, dynamic>{};

Clients _$ClientsFromJson(Map<String, dynamic> json) => Clients();

Map<String, dynamic> _$ClientsToJson(Clients instance) => <String, dynamic>{};

KnownClaims _$KnownClaimsFromJson(Map<String, dynamic> json) => KnownClaims();

Map<String, dynamic> _$KnownClaimsToJson(KnownClaims instance) =>
    <String, dynamic>{};

Roles _$RolesFromJson(Map<String, dynamic> json) => Roles();

Map<String, dynamic> _$RolesToJson(Roles instance) => <String, dynamic>{};

Scopes _$ScopesFromJson(Map<String, dynamic> json) => Scopes();

Map<String, dynamic> _$ScopesToJson(Scopes instance) => <String, dynamic>{};

KratosIdentityDTO _$KratosIdentityDTOFromJson(Map<String, dynamic> json) =>
    KratosIdentityDTO(
      id: json['Id'] as String,
      createdAt: DateTimeOffset.fromJson(json['CreatedAt'] as String),
      updatedAt: DateTimeOffset.fromJson(json['UpdatedAt'] as String),
      schemaId: json['SchemaId'] as String,
      email: json['Email'] as String,
    );

Map<String, dynamic> _$KratosIdentityDTOToJson(KratosIdentityDTO instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'CreatedAt': instance.createdAt,
      'UpdatedAt': instance.updatedAt,
      'SchemaId': instance.schemaId,
      'Email': instance.email,
    };

SearchIdentities _$SearchIdentitiesFromJson(Map<String, dynamic> json) =>
    SearchIdentities(
      pageNumber: json['PageNumber'] as int,
      pageSize: json['PageSize'] as int,
      schemaId: json['SchemaId'] as String?,
      emailPattern: json['EmailPattern'] as String?,
      givenNamePattern: json['GivenNamePattern'] as String?,
      familyNamePattern: json['FamilyNamePattern'] as String?,
    );

Map<String, dynamic> _$SearchIdentitiesToJson(SearchIdentities instance) =>
    <String, dynamic>{
      'PageNumber': instance.pageNumber,
      'PageSize': instance.pageSize,
      'SchemaId': instance.schemaId,
      'EmailPattern': instance.emailPattern,
      'GivenNamePattern': instance.givenNamePattern,
      'FamilyNamePattern': instance.familyNamePattern,
    };

PaginatedResult<TResult> _$PaginatedResultFromJson<TResult>(
  Map<String, dynamic> json,
  TResult Function(Object? json) fromJsonTResult,
) =>
    PaginatedResult<TResult>(
      items: (json['Items'] as List<dynamic>).map(fromJsonTResult).toList(),
      totalCount: json['TotalCount'] as int,
    );

Map<String, dynamic> _$PaginatedResultToJson<TResult>(
  PaginatedResult<TResult> instance,
  Object? Function(TResult value) toJsonTResult,
) =>
    <String, dynamic>{
      'Items': instance.items.map(toJsonTResult).toList(),
      'TotalCount': instance.totalCount,
    };

AddAssignmentsToProject _$AddAssignmentsToProjectFromJson(
        Map<String, dynamic> json) =>
    AddAssignmentsToProject(
      projectId: json['ProjectId'] as String,
      assignments: (json['Assignments'] as List<dynamic>)
          .map((e) => AssignmentDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AddAssignmentsToProjectToJson(
        AddAssignmentsToProject instance) =>
    <String, dynamic>{
      'ProjectId': instance.projectId,
      'Assignments': instance.assignments,
    };

AllProjects _$AllProjectsFromJson(Map<String, dynamic> json) => AllProjects(
      sortByNameDescending: json['SortByNameDescending'] as bool,
    );

Map<String, dynamic> _$AllProjectsToJson(AllProjects instance) =>
    <String, dynamic>{
      'SortByNameDescending': instance.sortByNameDescending,
    };

AssignmentDTO _$AssignmentDTOFromJson(Map<String, dynamic> json) =>
    AssignmentDTO(
      name: json['Name'] as String,
    );

Map<String, dynamic> _$AssignmentDTOToJson(AssignmentDTO instance) =>
    <String, dynamic>{
      'Name': instance.name,
    };

CreateProject _$CreateProjectFromJson(Map<String, dynamic> json) =>
    CreateProject(
      name: json['Name'] as String,
    );

Map<String, dynamic> _$CreateProjectToJson(CreateProject instance) =>
    <String, dynamic>{
      'Name': instance.name,
    };

ProjectDTO _$ProjectDTOFromJson(Map<String, dynamic> json) => ProjectDTO(
      id: json['Id'] as String,
      name: json['Name'] as String,
    );

Map<String, dynamic> _$ProjectDTOToJson(ProjectDTO instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
    };

ProjectDetails _$ProjectDetailsFromJson(Map<String, dynamic> json) =>
    ProjectDetails(
      id: json['Id'] as String,
    );

Map<String, dynamic> _$ProjectDetailsToJson(ProjectDetails instance) =>
    <String, dynamic>{
      'Id': instance.id,
    };

ProjectDetailsDTO _$ProjectDetailsDTOFromJson(Map<String, dynamic> json) =>
    ProjectDetailsDTO(
      id: json['Id'] as String,
      name: json['Name'] as String,
      assignments: (json['Assignments'] as List<dynamic>)
          .map((e) => AssignmentDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProjectDetailsDTOToJson(ProjectDetailsDTO instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
      'Assignments': instance.assignments,
    };

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

const _$PlatformDTOEnumMap = {
  PlatformDTO.android: 0,
  PlatformDTO.ios: 1,
};

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
