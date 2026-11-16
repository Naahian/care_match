import 'package:dio/dio.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/video_call_token.dart';
import '../../domain/repositories/video_call_repository.dart';
import '../models/video_call_token_model.dart';

class VideoCallRepositoryImpl implements VideoCallRepository {
  VideoCallRepositoryImpl({required this.dio});

  final Dio dio;

  @override
  Future<VideoCallToken> getToken(String appointmentId) async {
    final id = appointmentId.trim();
    if (id.isEmpty) {
      throw ArgumentError.value(appointmentId, 'appointmentId');
    }
    try {
      final response = await dio.post<Object?>(
        ApiEndpoints.video,
        data: {'appointment_id': id},
      );
      final data = ApiResponse.fromJson(response.data).data;
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Expected a video token object.');
      }
      return VideoCallTokenModel.fromJson(data, appointmentId: id);
    } on DioException catch (error) {
      throw VideoCallException(
        _message(error.response?.statusCode),
        cause: error,
        statusCode: error.response?.statusCode,
      );
    } on ApiResponseException catch (error) {
      throw VideoCallException(
        _message(error.statusCode),
        cause: error,
        statusCode: error.statusCode,
      );
    } on FormatException catch (error) {
      throw VideoCallException(
        'The video service returned an invalid response.',
        cause: error,
      );
    }
  }

  String _message(int? statusCode) => switch (statusCode) {
    401 => 'Sign in again before joining a video consultation.',
    403 => 'You do not have permission to join this consultation.',
    404 => 'This appointment does not have a video consultation.',
    _ => 'Could not prepare the video consultation. Please try again.',
  };
}
