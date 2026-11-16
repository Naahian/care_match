enum RecordKind { medicalReports, prescriptions }

class PatientRecord {
  const PatientRecord({
    required this.filename,
    required this.path,
    required this.contentType,
    required this.sizeBytes,
    required this.downloadUrl,
    required this.expiresAt,
    this.createdAt,
  });
  final String filename, path, contentType, downloadUrl;
  final int sizeBytes;
  final DateTime expiresAt;
  final DateTime? createdAt;
  bool get isImage => contentType.startsWith('image/');
}

class RecordPage {
  const RecordPage(this.records, this.nextOffset);
  final List<PatientRecord> records;
  final int? nextOffset;
}

abstract interface class RecordsRepository {
  Future<RecordPage> list(RecordKind kind, {int offset = 0});
}
