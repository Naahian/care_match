import '../entities/payment_checkout.dart';

abstract interface class PaymentsRepository {
  Future<String> createAppointment(BookingDetails booking);
  Future<PaymentCheckout> createPayment(PaymentRequest request);
  Future<PaymentCheckout> getPayment(String paymentId);
}

class PaymentException implements Exception {
  const PaymentException(this.message, {this.uncertainBooking = false});
  final String message;
  final bool uncertainBooking;
}
