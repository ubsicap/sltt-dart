// Generated helper constants and accessors for domain types and collections
import 'package:sltt_core/sltt_core.dart' show EntityType;

const String kDomainProject = 'project';
const String kCollectionProject = 'projects';

const String kDomainUser = 'user';
const String kCollectionUser = 'users';

const String kDomainMembership = 'membership';
const String kCollectionMembership = 'memberships';

enum DomainType {
  project(value: kDomainProject),
  user(value: kDomainUser),
  membership(value: kDomainMembership),
  unknown(value: 'unknown');

  final String value;

  const DomainType({required this.value});

  static DomainType tryFromString(String value) {
    switch (value) {
      case kDomainProject:
        return DomainType.project;
      case kDomainUser:
        return DomainType.user;
      case kDomainMembership:
        return DomainType.membership;
      default:
        return DomainType.unknown;
    }
  }

  String get collectionName {
    switch (this) {
      case DomainType.project:
        return kCollectionProject;
      case DomainType.user:
        return kCollectionUser;
      case DomainType.membership:
        return kCollectionMembership;
      case DomainType.unknown:
        throw Exception('Unknown domain type does not have a collection name');
    }
  }
}

const String kDomainEntityRootParentId = 'root';

class DomainTypeProfile {
  final DomainType domainType;
  final EntityType domainIdEntityType;
  final String rootEntityIdParentProp;
  final EntityType rootEntityIdEntityType;

  String get rootParentId => kDomainEntityRootParentId;
  bool get hasSharedEntityType => domainIdEntityType == rootEntityIdEntityType;
  bool get hasSeparateDomainIdEntityType => !hasSharedEntityType;

  const DomainTypeProfile({
    required this.domainType,
    required this.domainIdEntityType,
    required this.rootEntityIdEntityType,
    required this.rootEntityIdParentProp,
  });
}

Map<String, DomainTypeProfile> _domainTypeRootEntityProfiles = {
  kDomainProject: const DomainTypeProfile(
    domainType: DomainType.project,
    domainIdEntityType: EntityType.project,
    rootEntityIdEntityType: EntityType.project,
    rootEntityIdParentProp: kCollectionProject,
  ),
  kDomainUser: const DomainTypeProfile(
    domainType: DomainType.user,
    domainIdEntityType: EntityType.userProfile,
    rootEntityIdEntityType: EntityType.userProfile,
    rootEntityIdParentProp: kCollectionUser,
  ),

  /// Note: membership domain has a different entity type for domainId (project) vs rootEntityId (member)
  /// this allows us to capture multiple members per project,
  /// and also a reverse GSI on entityId (userId) to query all memberships
  /// for a user across all their projects.
  kDomainMembership: const DomainTypeProfile(
    domainType: DomainType.membership,
    domainIdEntityType: EntityType.project,
    rootEntityIdEntityType: EntityType.member,
    rootEntityIdParentProp: kCollectionMembership,
  ),
};

DomainTypeProfile? getDomainTypeProfile(String domainType) {
  return _domainTypeRootEntityProfiles[domainType];
}

String? getDomainRootEntityType(String domainType) {
  return _domainTypeRootEntityProfiles[domainType]
      ?.rootEntityIdEntityType
      .value;
}

/// Returns all supported domain types.
List<String> getAllDomainTypes() => _domainTypeRootEntityProfiles.keys.toList();

/// Returns the collection name for a given domain type.
/// Example: getCollectionByDomain('project') → 'projects'
String? getCollectionByDomain(String domainType) {
  switch (domainType) {
    case kDomainProject:
      return kCollectionProject;
    case kDomainUser:
      return kCollectionUser;
    case kDomainMembership:
      return kCollectionMembership;
    default:
      return null;
  }
}

/// Returns the domain type for a given collection name.
/// Example: getDomainByCollection('projects') → 'project'
String? getDomainByCollection(String collectionName) {
  switch (collectionName) {
    case kCollectionProject:
      return kDomainProject;
    case kCollectionUser:
      return kDomainUser;
    case kCollectionMembership:
      return kDomainMembership;
    default:
      return null;
  }
}

/// API Helper Documentation
///
/// ## API Helper Functions
///
/// - `getAllDomainTypes()`
///   Returns a list of all supported domain types.
///
/// - `getCollectionByDomain(String domainType)`
///   Returns the collection name for a given domain type, or null if not found.
///   Example: `getCollectionByDomain('project')` → `'projects'`
///
/// - `getDomainByCollection(String collectionName)`
///   Returns the domain type for a given collection name, or null if not found.
///   Example: `getDomainByCollection('projects')` → `'project'`
