import '../entities/profile_photo.dart';

abstract interface class ProfilePhotoPicker {
  Future<ProfilePhoto?> pickPhoto();
}
