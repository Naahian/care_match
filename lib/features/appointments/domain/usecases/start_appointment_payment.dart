import '../entities/payment_checkout.dart';
import '../repositories/payments_repository.dart';

/// One instance per booking attempt. Retains checkpoints for safe retries.
class StartAppointmentPayment {
  StartAppointmentPayment({required this.repository, required this.newKey});
  final PaymentsRepository repository;
  final String Function() newKey;
  String? _appointmentId;
  PaymentRequest? _request;
  bool _uncertainBooking = false;

  Future<PaymentCheckout> call(
    BookingDetails booking,
    BillingDetails billing,
  ) async {
    if (_uncertainBooking) {
      throw const PaymentException(
        'Check My appointments before starting another booking.',
        uncertainBooking: true,
      );
    }
    if (booking.amountCents <= 0 ||
        !booking.scheduledFor.isAfter(DateTime.now())) {
      throw const PaymentException(
        'Choose a future appointment with a valid price.',
      );
    }
    if (_appointmentId == null) {
      try {
        _appointmentId = await repository.createAppointment(booking);
      } on PaymentException catch (error) {
        _uncertainBooking = error.uncertainBooking;
        rethrow;
      }
    }
    _request ??= PaymentRequest(
      appointmentId: _appointmentId!,
      amountCents: booking.amountCents,
      idempotencyKey: newKey(),
      billing: billing,
    );
    return repository.createPayment(_request!);
  }
}
