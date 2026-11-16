import '../../domain/entities/user_profile.dart';

class ProfileState {
  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.saveError,
  });

  final UserProfile? profile;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? saveError;

  static String display(String? value) =>
      value == null || value.trim().isEmpty ? 'unknown' : value.trim();

  String ageLabel(DateTime now) {
    final birth = profile?.dateOfBirth;
    if (birth == null || birth.isAfter(now)) return 'unknown';
    final age =
        now.year -
        birth.year -
        (now.month < birth.month ||
                (now.month == birth.month && now.day < birth.day)
            ? 1
            : 0);
    return '$age years old';
  }
}
