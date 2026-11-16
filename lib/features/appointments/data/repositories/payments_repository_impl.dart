import 'package:dio/dio.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/payment_checkout.dart';
import '../../domain/repositories/payments_repository.dart';
import '../models/payment_checkout_model.dart';

class PaymentsRepositoryImpl implements PaymentsRepository {
  PaymentsRepositoryImpl({required this.dio});
  final Dio dio;

  Future<T> _request<T>(
    Future<T> Function() action, {
    bool booking = false,
  }) async {
    try {
      return await action();
    } on DioException catch (error) {
      final code = error.response?.statusCode;
      final uncertain = booking && (code == null || code >= 500);
      throw PaymentException(
        uncertain
            ? 'Booking could not be confirmed. Check My appointments before trying again.'
            : switch (code) {
                401 => 'Sign in again to continue payment.',
                403 => 'You do not have permission to make this payment.',
                409 =>
                  'Payment initialization is incomplete. Check your payment before starting again.',
                503 =>
                  'Payment service is unavailable. Please try again later.',
                _ => 'Could not complete the request. Please try again.',
              },
        uncertainBooking: uncertain,
      );
    } on FormatException {
      throw PaymentException(
        'The server response could not be confirmed.',
        uncertainBooking: booking,
      );
    } on ApiResponseException {
      throw PaymentException(
        'The server could not confirm the request.',
        uncertainBooking: booking,
      );
    }
  }

  @override
  Future<String> createAppointment(BookingDetails booking) =>
      _request(() async {
        final response = await dio.post<Object?>(
          ApiEndpoints.appointments,
          data: {
            'doctor_id': booking.doctorId,
            'patient_id': booking.patientId,
            'appointment_type': booking.type.value,
            'scheduled_for': booking.scheduledFor.toUtc().toIso8601String(),
            'reason': booking.reason.isEmpty
                ? 'Medical consultation'
                : booking.reason,
            'notes': booking.notes,
          },
        );
        final data = ApiResponse.fromJson(response.data).data;
        if (data is! Map<String, dynamic> ||
            data['appointment_id'] is! String ||
            (data['appointment_id'] as String).isEmpty ||
            data['patient_id'] != booking.patientId ||
            data['doctor_id'] != booking.doctorId) {
          throw const FormatException('Invalid appointment response');
        }
        return data['appointment_id'] as String;
      }, booking: true);

  @override
  Future<PaymentCheckout> createPayment(PaymentRequest request) =>
      _request(() async {
        final response = await dio.post<Object?>(
          ApiEndpoints.payments,
          data: PaymentCheckoutModel.request(request),
        );
        final payment = PaymentCheckoutModel.fromJson(
          ApiResponse.fromJson(response.data).data,
        );
        if (payment.appointmentId != request.appointmentId ||
            payment.amountCents != request.amountCents ||
            payment.currency != 'BDT') {
          throw const FormatException('Mismatched payment');
        }
        return payment;
      });

  @override
  Future<PaymentCheckout> getPayment(String paymentId) => _request(() async {
    final response = await dio.get<Object?>(
      ApiEndpoints.paymentStatus(Uri.encodeComponent(paymentId)),
    );
    final payment = PaymentCheckoutModel.fromJson(
      ApiResponse.fromJson(response.data).data,
    );
    if (payment.id != paymentId) {
      throw const FormatException('Mismatched payment');
    }
    return payment;
  });
}
