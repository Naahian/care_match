import 'package:dio/dio.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({required this.dio});

  final Dio dio;

  @override
  Future<UserProfile> getProfile() =>
      _request(() => dio.get<Object?>(ApiEndpoints.profile));

  @override
  Future<UserProfile> updateProfile(ProfileUpdate update) async {
    final error = update.validationError;
    if (error != null) throw ProfileException(error);
    final fields = UserProfileModel.updateJson(update);
    final photo = update.photo;
    final body = FormData.fromMap({
      for (final entry in fields.entries) entry.key: entry.value ?? '',
      'remove_photo': update.removePhoto,
      if (photo != null)
        'photo': MultipartFile.fromBytes(photo.bytes, filename: photo.filename),
    });
    return _request(
      () => dio.patch<Object?>(ApiEndpoints.profile, data: body),
      updating: true,
    );
  }

  Future<UserProfile> _request(
    Future<Response<Object?>> Function() request, {
    bool updating = false,
  }) async {
    final action = updating ? 'save' : 'load';
    try {
      final response = await request();
      final data = ApiResponse.fromJson(response.data).data;
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Expected a profile object.');
      }
      return UserProfileModel.fromJson(data);
    } on DioException catch (error) {
      throw ProfileException(
        error.response?.statusCode == 401
            ? 'Sign in again to $action your profile.'
            : error.response?.statusCode == 413
            ? 'Choose a photo smaller than 5 MB.'
            : error.response?.statusCode == 415
            ? 'Choose a JPEG, PNG, or WebP photo.'
            : updating && [400, 409, 422].contains(error.response?.statusCode)
            ? 'Check your profile details and phone number, then try again.'
            : 'Could not $action your profile. Please try again.',
        cause: error,
        statusCode: error.response?.statusCode,
      );
    } on ApiResponseException catch (error) {
      throw ProfileException(
        error.statusCode == 401
            ? 'Sign in again to $action your profile.'
            : 'Could not $action your profile. Please try again.',
        cause: error,
        statusCode: error.statusCode,
      );
    } on FormatException catch (error) {
      throw ProfileException('The profile response was invalid.', cause: error);
    }
  }
}
