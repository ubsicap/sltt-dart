import 'package:sltt_core/sltt_core.dart'
    show WebsocketConstants, getDomainTypeProfile;

bool isDomainTypeWithSeparateDomainIdAndRootEntityType(String domainType) {
  final profile = getDomainTypeProfile(domainType);
  return profile != null && profile.hasSeparateDomainIdEntityType;
}

String? getRootNotificationTypeForDomain(String domainType) {
  final profile = getDomainTypeProfile(domainType);
  if (profile == null) return null;

  return profile.hasSeparateDomainIdEntityType
      ? WebsocketConstants.notifyTypeAddedMe
      : WebsocketConstants.notifyTypeNewDomainId;
}

bool isValidRootEntitySubscriptionRequest({
  required String domainType,
  required String entityType,
  required String notifyType,
  String? userId,
}) {
  final profile = getDomainTypeProfile(domainType);
  if (profile == null) return false;

  final isSeparateDomainIdType = profile.hasSeparateDomainIdEntityType;
  final rootEntityType = profile.rootEntityIdEntityType.value;

  if (notifyType == WebsocketConstants.notifyTypeAddedMe) {
    return isSeparateDomainIdType &&
        entityType == rootEntityType &&
        userId != null &&
        userId.isNotEmpty;
  }

  if (notifyType == WebsocketConstants.notifyTypeNewDomainId) {
    return !isSeparateDomainIdType && entityType == rootEntityType;
  }

  return false;
}
