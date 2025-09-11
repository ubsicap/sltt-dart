// Generated helper constants and accessors for domain types and collections
const String kDomainProject = 'project';
const String kCollectionProject = 'projects';

List<String> getAllDomainTypes() => [kDomainProject];

/// Returns a list of collection mappings in the same shape used by the API
List<Map<String, String>> getCollectionsList() => [
  {kDomainProject: kCollectionProject},
];

/// Returns a simple map for programmatic lookups
Map<String, String> getCollectionsMap() => {kDomainProject: kCollectionProject};
