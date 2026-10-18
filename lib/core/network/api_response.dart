/// The common backend envelope. Each feature decodes [data] independently.
class ApiResponse {
  const ApiResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  final int status;
  final String msg;
  final Object? data;

  factory ApiResponse.fromJson(Object? json) {
    if (json is! Map<String, dynamic> ||
        json['status'] is! int ||
        json['msg'] is! String ||
        !json.containsKey('data')) {
      throw const FormatException(
        'Expected an API response with status, msg, and data.',
      );
    }
    final response = ApiResponse(
      status: json['status'] as int,
      msg: json['msg'] as String,
      data: json['data'],
    );
    if (response.status < 200 || response.status >= 300) {
      throw ApiResponseException(response.status, response.msg);
    }
    return response;
  }
}

class ApiResponseException implements Exception {
  const ApiResponseException(this.statusCode, this.message);

  final int statusCode;
  final String message;
}
