import 'package:dio/dio.dart';
import '../../../core/constants/constants.dart';
import '../../../core/network/api_response.dart';
import '../domain/patient_record.dart';

class RecordsRepositoryImpl implements RecordsRepository {
  RecordsRepositoryImpl(this.dio);
  final Dio dio;

  @override
  Future<RecordPage> list(RecordKind kind, {int offset = 0}) async {
    final prescriptions = kind == RecordKind.prescriptions;
    final response = await dio.get<Object?>(
      prescriptions ? ApiEndpoints.prescriptions : ApiEndpoints.medicalReports,
      queryParameters: {
        'limit': AppConstants.defaultPageSize,
        'offset': offset,
      },
    );
    final data = ApiResponse.fromJson(response.data).data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid records');
    }
    final items = data[prescriptions ? 'prescriptions' : 'reports'];
    if (items is! List) throw const FormatException('Invalid records');
    final records = items.map((item) {
      final json = item as Map<String, dynamic>;
      final url = json['download_url'] as String;
      final uri = Uri.parse(url);
      if (!uri.hasAuthority || !['https', 'http'].contains(uri.scheme)) {
        throw const FormatException('Invalid download URL');
      }
      return PatientRecord(
        filename: json['filename'] as String,
        path: json['path'] as String,
        contentType: json['content_type'] as String,
        sizeBytes: json['size_bytes'] as int,
        downloadUrl: url,
        expiresAt: DateTime.parse(json['expires_at'] as String),
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      );
    }).toList();
    return RecordPage(List.unmodifiable(records), data['next_offset'] as int?);
  }
}
