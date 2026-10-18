import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    super.displayName,
    super.email,
    super.dateOfBirth,
    super.gender,
    super.bloodGroup,
    super.preferredLanguage,
    super.photoUrl,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    String? text(String key) {
      final value = json[key];
      return value is String && value.trim().isNotEmpty ? value.trim() : null;
    }

    final birthDate = text('date_of_birth');
    DateTime? parsedDate;
    if (birthDate != null) {
      final match = RegExp(
        r'^(\d{4})-(\d{2})-(\d{2})(?:T.*)?$',
      ).firstMatch(birthDate);
      if (match != null) {
        final year = int.parse(match[1]!);
        final month = int.parse(match[2]!);
        final day = int.parse(match[3]!);
        final date = DateTime(year, month, day);
        if (date.year == year && date.month == month && date.day == day) {
          parsedDate = date;
        }
      }
    }
    final photo = text('photo_url');
    final uri = photo == null ? null : Uri.tryParse(photo);
    return UserProfileModel(
      displayName: text('display_name'),
      email: text('email'),
      dateOfBirth: parsedDate,
      gender: text('gender'),
      bloodGroup: text('blood_group'),
      preferredLanguage: text('preferred_language'),
      photoUrl:
          uri != null &&
              uri.hasAuthority &&
              (uri.scheme == 'https' || uri.scheme == 'http')
          ? photo
          : null,
    );
  }
}
