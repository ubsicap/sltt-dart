// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoteData _$NoteDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('NoteData', json, ($checkedConvert) {
      final val = NoteData(
        title: $checkedConvert('title', (v) => v as String),
        videoCommentId: $checkedConvert('videoCommentId', (v) => v as String?),
        videoCommentStoredFilename: $checkedConvert(
          'videoCommentStoredFilename',
          (v) => v as String?,
        ),
        videoCommentDurationMs: $checkedConvert(
          'videoCommentDurationMs',
          (v) => (v as num?)?.toInt(),
        ),
        textComment: $checkedConvert('textComment', (v) => v as String?),
        markerId: $checkedConvert('markerId', (v) => v as String),
        positionMs: $checkedConvert('positionMs', (v) => (v as num).toInt()),
        resolution: $checkedConvert('resolution', (v) => v as String),
        parentId: $checkedConvert('parentId', (v) => v as String),
        parentProp: $checkedConvert('parentProp', (v) => v as String),
        rank: $checkedConvert('rank', (v) => v as String?),
        deleted: $checkedConvert('deleted', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$NoteDataToJson(NoteData instance) => <String, dynamic>{
  'parentId': instance.parentId,
  'parentProp': instance.parentProp,
  'rank': ?instance.rank,
  'deleted': ?instance.deleted,
  'title': instance.title,
  'videoCommentId': ?instance.videoCommentId,
  'videoCommentStoredFilename': ?instance.videoCommentStoredFilename,
  'videoCommentDurationMs': ?instance.videoCommentDurationMs,
  'textComment': ?instance.textComment,
  'markerId': instance.markerId,
  'positionMs': instance.positionMs,
  'resolution': instance.resolution,
};
