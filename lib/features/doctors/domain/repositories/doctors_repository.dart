import '../entities/doctor.dart';

abstract interface class DoctorsRepository {
  Future<List<Doctor>> getDoctors();
}

class DoctorsException implements Exception {
  const DoctorsException(this.message, {this.cause, this.statusCode});
  final String message;
  final Object? cause;
  final int? statusCode;
}
