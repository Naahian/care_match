import '../entities/user_profile.dart';
import '../entities/profile_update.dart';

export '../entities/profile_update.dart';

abstract interface class ProfileRepository {
  Future<UserProfile> getProfile();
  Future<UserProfile> updateProfile(ProfileUpdate update);
}

class ProfileException implements Exception {
  const ProfileException(this.message, {this.cause, this.statusCode});

  final String message;
  final Object? cause;
  final int? statusCode;
}
