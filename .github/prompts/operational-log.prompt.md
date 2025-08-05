- update the model so that it includes a general operation log, instead of `documents`
- update the api and tests to refer to the operational log using `/api/changes`
- remove `/api/documents/search/<query>` endpoint
- remove sync endpoints

@Collection()
class ChangeLogEntry {
  Id id = Isar.autoIncrement;

  late String entityType; // e.g., 'document', 'Passage', 'Portion'
  late String operation;  // e.g., 'create', 'update', 'delete'
  late DateTime timestamp;
  late String entityId;   // UUID or primary key of the entity
  late String dataJson;   // JSON-encoded entity data

  Map<String, dynamic> get data => jsonDecode(dataJson);
  set data(Map<String, dynamic> value) => dataJson = jsonEncode(value);

  ChangeLogEntry({
    required this.entityType,
    required this.operation,
    required this.timestamp,
    required this.entityId,
    required Map<String, dynamic> data,
  }) {
    dataJson = jsonEncode(data);
  }
}
