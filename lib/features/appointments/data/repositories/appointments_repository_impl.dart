import 'package:dio/dio.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointments_repository.dart';
import '../models/appointment_model.dart';

class AppointmentsRepositoryImpl implements AppointmentsRepository {
  AppointmentsRepositoryImpl({required this.dio});
  final Dio dio;

  @override
  Future<List<Appointment>> getAppointments() async {
    try {
      final response = await dio.get<Object?>(
        ApiEndpoints.appointments,
        queryParameters: {'role': 'patient'},
      );
      final data = ApiResponse.fromJson(response.data).data;
      if (data is! List) {
        throw const FormatException('Expected an appointment list.');
      }
      final ids = <String>{};
      return List.unmodifiable(
        data.map((item) {
          final appointment = _appointment(item);
          if (!ids.add(appointment.id)) {
            throw const FormatException('Duplicate appointment identifier.');
          }
          return appointment;
        }),
      );
    } on DioException catch (error) {
      throw _networkError(error);
    } on ApiResponseException catch (error) {
      throw _responseError(error);
    } on FormatException catch (error) {
      throw AppointmentsException(
        'The appointments response was invalid.',
        cause: error,
      );
    }
  }

  @override
  Future<Appointment> updateStatus({
    required String appointmentId,
    required AppointmentStatus status,
  }) async {
    if (appointmentId.trim().isEmpty) {
      throw ArgumentError.value(appointmentId, 'appointmentId');
    }
    try {
      final response = await dio.patch<Object?>(
        ApiEndpoints.appointmentStatus(Uri.encodeComponent(appointmentId)),
        queryParameters: {'new_status': status.name},
      );
      final appointment = _appointment(
        ApiResponse.fromJson(response.data).data,
      );
      if (appointment.id != appointmentId || appointment.status != status) {
        throw const FormatException(
          'The updated appointment did not match the request.',
        );
      }
      return appointment;
    } on DioException catch (error) {
      throw _networkError(error, updating: true);
    } on ApiResponseException catch (error) {
      throw _responseError(error, updating: true);
    } on FormatException catch (error) {
      throw AppointmentsException(
        'The update could not be confirmed. Refresh appointments before trying again.',
        cause: error,
        mayHaveSucceeded: true,
      );
    }
  }

  Appointment _appointment(Object? data) {
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Expected an appointment object.');
    }
    return AppointmentModel.fromJson(data);
  }

  AppointmentsException _networkError(
    DioException error, {
    bool updating = false,
  }) {
    final uncertain =
        updating &&
        (error.response == null || (error.response!.statusCode ?? 0) >= 500);
    return AppointmentsException(
      uncertain
          ? 'The update could not be confirmed. Refresh appointments before trying again.'
          : _message(error.response?.statusCode, updating),
      cause: error,
      statusCode: error.response?.statusCode,
      mayHaveSucceeded: uncertain,
    );
  }

  AppointmentsException _responseError(
    ApiResponseException error, {
    bool updating = false,
  }) => AppointmentsException(
    _message(error.statusCode, updating),
    cause: error,
    statusCode: error.statusCode,
  );

  String _message(int? code, bool updating) => switch (code) {
    401 => 'Sign in again to access your appointments.',
    403 => 'You do not have permission to access this appointment.',
    404 when updating =>
      'This appointment no longer exists. Refresh your appointments.',
    409 when updating =>
      'This appointment has changed. Refresh your appointments.',
    _ =>
      updating
          ? 'Could not update this appointment. Please try again.'
          : 'Could not load appointments. Please try again.',
  };
}
