import '../../../appointments/presentation/models/appointment_draft.dart';

enum PaymentStatus { succeeded, failed, pending }

class PaymentReceipt {
  const PaymentReceipt({
    required this.reference,
    required this.provider,
    required this.amount,
    required this.paidAt,
    this.description = 'Doctor consultation',
  });
  final String reference;
  final String provider;
  final String amount;
  final DateTime paidAt;
  final String description;
}

class PaymentVerification {
  const PaymentVerification.succeeded(PaymentReceipt this.receipt)
    : status = PaymentStatus.succeeded,
      message = null;
  const PaymentVerification.failed([this.message])
    : status = PaymentStatus.failed,
      receipt = null;
  const PaymentVerification.pending([this.message])
    : status = PaymentStatus.pending,
      receipt = null;
  final PaymentStatus status;
  final PaymentReceipt? receipt;
  final String? message;
}

/// Populate from a backend-created hosted checkout session. Verification must
/// query the backend's payment status, rather than trusting a return URL.
class PaymentCheckoutSession {
  PaymentCheckoutSession({
    required this.appointmentDraft,
    required this.provider,
    required this.amount,
    required this.checkoutUrl,
    required this.successReturnUrl,
    required this.failureReturnUrl,
    required this.verifyPayment,
    this.createRetrySession,
    Set<String> allowedHosts = const {},
  }) : allowedHosts = Set.unmodifiable({
         checkoutUrl.host.toLowerCase(),
         ...allowedHosts.map((host) => host.toLowerCase()),
       }) {
    for (final url in [checkoutUrl, successReturnUrl, failureReturnUrl]) {
      if (url.scheme != 'https' ||
          url.host.isEmpty ||
          url.userInfo.isNotEmpty) {
        throw ArgumentError(
          'Checkout and return URLs must be HTTPS endpoints.',
        );
      }
    }
    if (_matchesReturn(successReturnUrl, failureReturnUrl) ||
        _matchesReturn(failureReturnUrl, successReturnUrl)) {
      throw ArgumentError('Success and failure return URLs must be distinct.');
    }
  }
  final String provider;
  final String amount;
  final Uri checkoutUrl;
  final AppointmentDraft appointmentDraft;
  final Uri successReturnUrl;
  final Uri failureReturnUrl;
  final Set<String> allowedHosts;
  final Future<PaymentVerification> Function() verifyPayment;
  final Future<PaymentCheckoutSession> Function()? createRetrySession;

  bool isReturnUrl(Uri url) =>
      _matchesReturn(url, successReturnUrl) ||
      _matchesReturn(url, failureReturnUrl);
  bool allowsNavigation(Uri url) =>
      url.scheme == 'https' &&
      url.userInfo.isEmpty &&
      allowedHosts.contains(url.host.toLowerCase());

  static bool _matchesReturn(Uri url, Uri expected) =>
      url.scheme == expected.scheme &&
      url.host == expected.host &&
      url.port == expected.port &&
      url.path == expected.path &&
      url.userInfo.isEmpty &&
      expected.queryParametersAll.entries.every((entry) {
        final actual = url.queryParametersAll[entry.key];
        return actual != null &&
            actual.length == entry.value.length &&
            List.generate(
              actual.length,
              (index) => actual[index] == entry.value[index],
            ).every((matches) => matches);
      });
}

class PaymentFailure {
  const PaymentFailure({
    this.message =
        'Your payment could not be completed. Please check your payment method and try again.',
    this.session,
  });
  final String message;
  final PaymentCheckoutSession? session;
}
