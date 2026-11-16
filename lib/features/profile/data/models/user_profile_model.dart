import '../../domain/entities/user_profile.dart';
import '../../domain/entities/profile_update.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    super.displayName,
    super.email,
    super.phoneNumber,
    super.dateOfBirth,
    super.gender,
    super.bloodGroup,
    super.preferredLanguage,
    super.photoUrl,
    super.role,
    super.totalEarnings,
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
      phoneNumber: text('phone_number'),
      dateOfBirth: parsedDate,
      gender: text('gender'),
      bloodGroup: text('blood_group'),
      preferredLanguage: text('preferred_language'),
      role: text('role'),
      totalEarnings:
          json['total_earnings'] is int && (json['total_earnings'] as int) >= 0
          ? json['total_earnings'] as int
          : null,
      photoUrl:
          uri != null &&
              uri.hasAuthority &&
              (uri.scheme == 'https' || uri.scheme == 'http')
          ? photo
          : null,
    );
  }

  static Map<String, Object?> updateJson(ProfileUpdate update) {
    String? value(String text) => text.trim().isEmpty ? null : text.trim();
    final birth = update.dateOfBirth;
    return {
      'display_name': value(update.displayName),
      'phone_number': value(update.phoneNumber),
      if (update.removePhoto) 'remove_photo': true,
      'date_of_birth': birth == null
          ? null
          : '${birth.year.toString().padLeft(4, '0')}-'
                '${birth.month.toString().padLeft(2, '0')}-'
                '${birth.day.toString().padLeft(2, '0')}',
      'gender': value(update.gender ?? ''),
      'blood_group': value(update.bloodGroup ?? ''),
    };
  }
}
