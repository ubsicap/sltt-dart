import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'unknown_data_fields.g.dart';

/// Data fields specific to unknown entities.
/// Extends BaseDataFields with unknown-specific fields like name.
@JsonSerializable(includeIfNull: true, checked: true)
class UnknownDataFields extends BaseDataFields {
  String? name;

  UnknownDataFields({
    required super.parentId,
    required super.parentProp,
    super.rank,
    super.deleted,
    this.name,
  });

  factory UnknownDataFields.fromJson(Map<String, dynamic> json) =>
      _$UnknownDataFieldsFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$UnknownDataFieldsToJson(this)
        ..removeWhere((key, value) => value == null);
}
