import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'user_preferences.data.g.dart';

@JsonSerializable(includeIfNull: false, checked: true)
class UserPreferencesData extends BaseDataFields {
  // TODO: add actual preference fields here, e.g. theme, font size, etc.

  UserPreferencesData({
    required super.parentId,
    required super.parentProp,
    super.rank,
    super.deleted,
  });

  factory UserPreferencesData.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserPreferencesDataToJson(this);
}
