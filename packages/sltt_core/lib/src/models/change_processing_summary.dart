import 'package:json_annotation/json_annotation.dart';

part 'change_processing_summary.g.dart';

/// TODO separate into SaveChangesSummary and SyncChangesSummary?
/// Summary of results from processing changes through the change processing service
@JsonSerializable()
class ChangeProcessingSummary {
  /// The type of storage used (e.g., local, cloud)
  String storageType;

  /// The ID of the storage instance
  String storageId;

  /// A list of state updates applied
  List<Map<String, dynamic>> stateUpdates;

  /// A list of change updates applied
  List<Map<String, dynamic>> changeUpdates;

  /// A list of created entity IDs
  List<String> created;

  /// A list of updated entity IDs
  List<String> updated;

  /// A list of partially updated entity IDs (subset of updated)
  List<String> pUpdated;

  /// A list of deleted entity IDs
  List<String> deleted;

  /// A list of outdated entity IDs (received change is older than current state)
  List<String> outdated;

  /// A list of no-op entity IDs
  List<String> noOps;

  /// A list of clouded entity IDs (duplicates from the cloud)
  List<String> clouded;

  /// A list of duplicate entity IDs
  List<String> dups;

  /// A list of unknown entity data
  List<Map<String, dynamic>> unknowns;

  /// A list of informational messages
  List<Map<String, dynamic>> info;

  /// A list of error messages
  List<Map<String, dynamic>> errors;

  List<String> get processed => {
    ...created,
    ...updated,
    ...deleted,
    ...outdated,
    ...noOps,
    ...clouded,
    ...dups,
  }.toList();

  /// A list of unprocessed entity IDs
  List<String> unprocessed;

  ChangeProcessingSummary({
    required this.storageType,
    required this.storageId,
    required this.stateUpdates,
    required this.changeUpdates,
    required this.created,
    required this.updated,
    required this.pUpdated,
    required this.deleted,
    required this.outdated,
    required this.noOps,
    required this.clouded,
    required this.dups,
    required this.unknowns,
    required this.info,
    required this.errors,
    required this.unprocessed,
  });

  /// Create a ChangeProcessingSummary from a JSON map
  factory ChangeProcessingSummary.fromJson(Map<String, dynamic> json) =>
      _$ChangeProcessingSummaryFromJson(json);

  /// Convert the ChangeProcessingSummary to a JSON map
  Map<String, dynamic> toJson() => _$ChangeProcessingSummaryToJson(this);

  @override
  String toString() {
    return 'ChangeProcessingSummary(storageType: $storageType, storageId: $storageId, created: $created, updated: $updated, pUpdated: $pUpdated, deleted: $deleted, noOps: $noOps, clouded: $clouded, dups: $dups, unknowns: $unknowns, info: $info, errors: $errors, unprocessed: $unprocessed, stateUpdates: $stateUpdates, changeUpdates: $changeUpdates)';
  }
}
