import 'package:flutter/foundation.dart';
import '../models/payment_checkout_session.dart';

class PaymentCheckoutController extends ChangeNotifier {
  PaymentCheckoutController(this.session);

  final PaymentCheckoutSession session;
  bool verifying = false;
  bool _disposed = false;
  PaymentVerification? verification;

  Future<void> verify() async {
    if (verifying ||
        verification?.status == PaymentStatus.succeeded ||
        _disposed) {
      return;
    }
    verifying = true;
    notifyListeners();
    try {
      final result = await session.verifyPayment().timeout(
        const Duration(seconds: 30),
      );
      if (!_disposed) verification = result;
    } catch (_) {
      if (!_disposed) {
        verification = const PaymentVerification.pending(
          'We couldn’t confirm your payment yet. Check its status before making another payment.',
        );
      }
    } finally {
      verifying = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
