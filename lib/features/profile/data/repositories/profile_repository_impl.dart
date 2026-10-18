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
  Future<UserProfile> getProfile() async {
    try {
      final response = await dio.get<Object?>(ApiEndpoints.profile);
      final data = ApiResponse.fromJson(response.data).data;
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Expected a profile object.');
      }
      return UserProfileModel.fromJson(data);
    } on DioException catch (error) {
      throw ProfileException(
        error.response?.statusCode == 401
            ? 'Sign in again to load your profile.'
            : 'Could not load your profile. Please try again.',
        cause: error,
        statusCode: error.response?.statusCode,
      );
    } on ApiResponseException catch (error) {
      throw ProfileException(
        error.statusCode == 401
            ? 'Sign in again to load your profile.'
            : 'Could not load your profile. Please try again.',
        cause: error,
        statusCode: error.statusCode,
      );
    } on FormatException catch (error) {
      throw ProfileException('The profile response was invalid.', cause: error);
    }
  }
}
