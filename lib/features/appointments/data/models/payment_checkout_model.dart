import '../../domain/entities/payment_checkout.dart';

abstract final class PaymentCheckoutModel {
  static PaymentCheckout fromJson(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Invalid payment');
    }
    String field(String key) {
      final result = value[key];
      if (result is! String || result.trim().isEmpty) {
        throw FormatException('Invalid $key');
      }
      return result;
    }

    final amount = value['amount_cents'];
    if (amount is! int || amount <= 0) {
      throw const FormatException('Invalid amount');
    }
    final rawUrl = value['checkout_url'];
    final url = rawUrl == null
        ? null
        : Uri.tryParse(rawUrl is String ? rawUrl : '');
    if (rawUrl != null &&
        (url == null ||
            url.scheme != 'https' ||
            url.host.isEmpty ||
            url.userInfo.isNotEmpty)) {
      throw const FormatException('Invalid checkout URL');
    }
    return PaymentCheckout(
      id: field('payment_id'),
      appointmentId: field('appointment_id'),
      amountCents: amount,
      currency: field('currency'),
      status: field('status'),
      checkoutUrl: url,
    );
  }

  static Map<String, Object> request(PaymentRequest request) => {
    'appointment_id': request.appointmentId,
    'amount_cents': request.amountCents,
    'currency': 'BDT',
    'idempotency_key': request.idempotencyKey,
    'customer_name': request.billing.name,
    'customer_email': request.billing.email,
    'customer_phone': request.billing.phone,
    'customer_address': request.billing.address,
    'customer_city': request.billing.city,
    'customer_postcode': request.billing.postcode,
    'customer_country': 'Bangladesh',
  };
}
