class UserProfile {
  const UserProfile({
    this.displayName,
    this.email,
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
    this.preferredLanguage,
    this.photoUrl,
  });

  final String? displayName;
  final String? email;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bloodGroup;
  final String? preferredLanguage;
  final String? photoUrl;
}
