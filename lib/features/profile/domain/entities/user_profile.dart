class UserProfile {
  const UserProfile({
    this.displayName,
    this.email,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
    this.preferredLanguage,
    this.photoUrl,
    this.role,
    this.totalEarnings,
  });

  final String? displayName;
  final String? email;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bloodGroup;
  final String? preferredLanguage;
  final String? photoUrl;
  final String? role;

  /// All-time doctor earnings in BDT; null means the API did not provide it.
  final int? totalEarnings;
}
