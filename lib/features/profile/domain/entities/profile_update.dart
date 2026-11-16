import 'profile_photo.dart';

/// Editable account and personal details.
/// Empty values explicitly clear the corresponding profile field.
class ProfileUpdate {
  const ProfileUpdate({
    required this.displayName,
    required this.phoneNumber,
    this.photo,
    this.removePhoto = false,
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
  });

  final String displayName;
  final String phoneNumber;
  final ProfilePhoto? photo;
  final bool removePhoto;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bloodGroup;

  static const genders = ['Male', 'Female', 'Other'];
  static const bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  static String? validateDateOfBirth(DateTime? value) {
    if (value == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final birth = DateTime(value.year, value.month, value.day);
    return birth.isAfter(today)
        ? 'Date of birth cannot be in the future.'
        : null;
  }

  static String? validateName(String? value) =>
      (value?.trim().length ?? 0) > 128 ? 'Use 128 characters or fewer.' : null;

  static String? validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return null;
    return RegExp(r'^\+[1-9]\d{1,14}$').hasMatch(phone)
        ? null
        : 'Use an international number, such as +8801712345678.';
  }

  String? get validationError =>
      validateName(displayName) ??
      validatePhone(phoneNumber) ??
      validateDateOfBirth(dateOfBirth) ??
      (photo != null && removePhoto
          ? 'Choose a new photo or remove the current photo.'
          : photo != null &&
                (photo!.bytes.isEmpty ||
                    photo!.bytes.length > ProfilePhoto.maxBytes)
          ? 'Choose a valid photo smaller than 5 MB.'
          : null);
}
