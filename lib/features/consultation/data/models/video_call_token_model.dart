import '../../domain/entities/video_call_token.dart';

class VideoCallTokenModel extends VideoCallToken {
  const VideoCallTokenModel({required super.token, required super.channelName});

  factory VideoCallTokenModel.fromJson(
    Map<String, dynamic> json, {
    required String appointmentId,
  }) {
    final token = json['token'];
    final channelName = json['channelName'];
    if (token is! String ||
        token.trim().isEmpty ||
        channelName is! String ||
        channelName.trim() != appointmentId) {
      throw const FormatException('Invalid video token response.');
    }
    return VideoCallTokenModel(
      token: token.trim(),
      channelName: channelName.trim(),
    );
  }
}
