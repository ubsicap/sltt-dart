// Generated helper constants and accessors for domain types and collections
const String kProjectDomain = 'project';
const String kProjectCollection = 'projects';

List<String> getAllDomainTypes() => [kProjectDomain];

/// Returns a list of collection mappings in the same shape used by the API
List<Map<String, String>> getCollectionsList() => [
  {kProjectDomain: kProjectCollection},
];

/// Returns a simple map for programmatic lookups
Map<String, String> getCollectionsMap() => {kProjectDomain: kProjectCollection};
