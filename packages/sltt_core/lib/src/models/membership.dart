enum MemberType {
  system,
  // superAdmin, // use super user mode + admin instead of this role
  admin,
  translator,
  consultant,
  advisor,
  observer,
  unknown,
}

/// higher rank means more permissions
int getMemberRank(MemberType type) {
  switch (type) {
    case MemberType.system:
      return 6;
    // case MemberType.superAdmin:
    //   return 5;
    case MemberType.admin:
      return 4;
    case MemberType.translator:
      return 3;
    case MemberType.consultant:
      return 2;
    case MemberType.advisor:
      return 1;
    case MemberType.observer:
      return 0;
    case MemberType.unknown:
      return -1;
  }
}
