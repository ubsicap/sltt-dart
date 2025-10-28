import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'project_data_fields.g.dart';

/// Data fields specific to project entities.
/// Extends BaseDataFields with project-specific fields like nameLocal.
@JsonSerializable(includeIfNull: true, checked: true)
class ProjectDataFields extends BaseDataFields {
  String? nameLocal;

  ProjectDataFields({
    required super.parentId,
    required super.parentProp,
    super.rank,
    super.deleted,
    this.nameLocal,
  });

  factory ProjectDataFields.fromJson(Map<String, dynamic> json) =>
      _$ProjectDataFieldsFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$ProjectDataFieldsToJson(this)
        ..removeWhere((key, value) => value == null);
}
