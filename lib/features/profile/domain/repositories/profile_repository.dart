import '../entities/user_profile.dart';

abstract interface class ProfileRepository {
  Future<UserProfile> getProfile();
}

class ProfileException implements Exception {
  const ProfileException(this.message, {this.cause, this.statusCode});

  final String message;
  final Object? cause;
  final int? statusCode;
}
