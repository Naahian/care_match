import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/providers.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'domain/repositories/profile_repository.dart';
import 'domain/repositories/profile_photo_picker.dart';
import 'data/services/device_profile_photo_picker.dart';

final profilePhotoPickerProvider = Provider<ProfilePhotoPicker>(
  (ref) => DeviceProfilePhotoPicker(picker: ImagePicker()),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(dio: ref.watch(dioProvider)),
);
