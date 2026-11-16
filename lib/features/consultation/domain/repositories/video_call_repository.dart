import '../entities/video_call_token.dart';

abstract interface class VideoCallRepository {
  Future<VideoCallToken> getToken(String appointmentId);
}

class VideoCallException implements Exception {
  const VideoCallException(this.message, {this.cause, this.statusCode});

  final String message;
  final Object? cause;
  final int? statusCode;
}
