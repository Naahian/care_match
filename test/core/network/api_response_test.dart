import 'package:care_match/core/network/api_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preserves dynamic data for successful responses', () {
    for (final data in <Object?>[null, [], {}, 'value', 42, true]) {
      final response = ApiResponse.fromJson({
        'status': 201,
        'msg': 'Created',
        'data': data,
      });
      expect(response.status, 201);
      expect(response.msg, 'Created');
      expect(response.data, same(data));
    }
  });

  test('rejects API failures independently of HTTP status', () {
    expect(
      () => ApiResponse.fromJson({
        'status': 409,
        'msg': 'Conflict',
        'data': null,
      }),
      throwsA(
        isA<ApiResponseException>()
            .having((e) => e.statusCode, 'status', 409)
            .having((e) => e.message, 'message', 'Conflict'),
      ),
    );
  });

  test('rejects missing fields and malformed envelopes', () {
    for (final value in <Object?>[
      null,
      [],
      'invalid',
      {},
      {'status': 200, 'msg': 'Success'},
      {'status': '200', 'msg': 'Success', 'data': null},
      {'status': 200, 'msg': null, 'data': null},
    ]) {
      expect(() => ApiResponse.fromJson(value), throwsFormatException);
    }
  });
}
