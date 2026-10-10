import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../models/payment_checkout_session.dart';
import '../widgets/payment_details_card.dart';
import '../widgets/payment_status_content.dart';

class PaymentFailedScreen extends StatefulWidget {
  const PaymentFailedScreen({super.key, this.failure = const PaymentFailure()});
  final PaymentFailure failure;
  @override
  State<PaymentFailedScreen> createState() => _PaymentFailedScreenState();
}

class _PaymentFailedScreenState extends State<PaymentFailedScreen> {
  bool _retrying = false;
  Future<void> _retry() async {
    final createSession = widget.failure.session?.createRetrySession;
    if (createSession == null || _retrying) return;
    setState(() => _retrying = true);
    try {
      final session = await createSession().timeout(
        const Duration(seconds: 30),
      );
      if (mounted) {
        context.pushReplacementNamed(AppRoutes.paymentCheckout, extra: session);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Couldn’t start a new checkout. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.failure.session;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: PaymentStatusContent(
        icon: Icons.close_rounded,
        isError: true,
        title: 'Payment not completed',
        message: widget.failure.message,
        details: session == null
            ? null
            : PaymentDetailsCard(
                details: {
                  'Amount': session.amount,
                  'Payment method': session.provider,
                },
              ),
        actionLabel: session?.createRetrySession == null
            ? 'Back to Home'
            : 'Try again',
        onAction: session?.createRetrySession == null
            ? () => context.goNamed(AppRoutes.home)
            : _retry,
        busy: _retrying,
        secondaryAction: session?.createRetrySession == null
            ? null
            : TextButton(
                onPressed: _retrying
                    ? null
                    : () => context.goNamed(AppRoutes.home),
                child: const Text('Back to Home'),
              ),
      ),
    );
  }
}
