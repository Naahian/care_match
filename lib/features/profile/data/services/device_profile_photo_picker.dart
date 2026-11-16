import 'package:image_picker/image_picker.dart';

import '../../domain/entities/profile_photo.dart';
import '../../domain/repositories/profile_photo_picker.dart';
import '../../domain/repositories/profile_repository.dart';

class DeviceProfilePhotoPicker implements ProfilePhotoPicker {
  DeviceProfilePhotoPicker({required this.picker});
  final ImagePicker picker;

  @override
  Future<ProfilePhoto?> pickPhoto() async {
    try {
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (file == null) return null;
      if (await file.length() > ProfilePhoto.maxBytes) {
        throw const ProfileException('Choose a photo smaller than 5 MB.');
      }
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty || bytes.length > ProfilePhoto.maxBytes) {
        throw const ProfileException('Choose a valid photo smaller than 5 MB.');
      }
      return ProfilePhoto(bytes: bytes, filename: file.name);
    } on ProfileException {
      rethrow;
    } catch (error) {
      throw ProfileException(
        'Could not open your photos. Please try again.',
        cause: error,
      );
    }
  }
}
