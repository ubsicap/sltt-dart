import 'package:json_annotation/json_annotation.dart';
import 'package:sltt_core/sltt_core.dart';

part 'user_preferences.data.g.dart';

@JsonSerializable(includeIfNull: false, checked: true)
class UserPreferencesData extends BaseDataFields {
  final String uiLocale;

  UserPreferencesData({
    required super.parentId,
    required super.parentProp,
    super.rank,
    super.deleted,
    // preference fields
    required this.uiLocale,
  });

  factory UserPreferencesData.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserPreferencesDataToJson(this);
}
