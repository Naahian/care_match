import 'appointment.dart';

class BillingDetails {
  const BillingDetails({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.postcode,
  });
  final String name, email, phone, address, city, postcode;
}

class BookingDetails {
  const BookingDetails({
    required this.doctorId,
    required this.patientId,
    required this.scheduledFor,
    required this.reason,
    required this.notes,
    required this.amountCents,
    this.type = AppointmentType.video,
  });
  final String doctorId, patientId, reason, notes;
  final DateTime scheduledFor;
  final int amountCents;
  final AppointmentType type;
}

class PaymentRequest {
  const PaymentRequest({
    required this.appointmentId,
    required this.amountCents,
    required this.idempotencyKey,
    required this.billing,
  });
  final String appointmentId, idempotencyKey;
  final int amountCents;
  final BillingDetails billing;
}

class PaymentCheckout {
  const PaymentCheckout({
    required this.id,
    required this.appointmentId,
    required this.amountCents,
    required this.currency,
    required this.status,
    this.checkoutUrl,
  });
  final String id, appointmentId, currency, status;
  final int amountCents;
  final Uri? checkoutUrl;
  bool get isPaid => status == 'paid';
  bool get isTerminal =>
      const {'paid', 'failed', 'cancelled', 'review'}.contains(status);
}
