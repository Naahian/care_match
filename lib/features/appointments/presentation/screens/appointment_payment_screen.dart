import 'package:care_match/shared/widgets/care_app_bar.dart';
import 'package:care_match/core/constants/constants.dart';
import 'package:care_match/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/providers.dart';
import '../controllers/checkout_controller.dart';
import '../widgets/payment_billing_form.dart';
import 'payment_checkout_screen.dart';
import '../../../notifications/domain/app_notification.dart';
import '../../../notifications/providers.dart';
import 'package:go_router/go_router.dart';
import '../models/appointment_draft.dart';
import '../widgets/appointment_continue_button.dart';
import '../widgets/appointment_summary_card.dart';
import '../widgets/appointment_payment_method_card.dart';
import '../widgets/appointment_price_details.dart';

class AppointmentPaymentScreen extends ConsumerStatefulWidget {
  const AppointmentPaymentScreen({super.key, required this.draft});
  final AppointmentDraft draft;
  @override
  ConsumerState<AppointmentPaymentScreen> createState() =>
      _AppointmentPaymentScreenState();
}

class _AppointmentPaymentScreenState
    extends ConsumerState<AppointmentPaymentScreen> {
  final _billingKey = GlobalKey<PaymentBillingFormState>();

  Future<void> _pay() async {
    final billing = _billingKey.currentState?.validate();
    if (billing == null) {
      final billingContext = _billingKey.currentContext;
      if (billingContext != null) {
        await Scrollable.ensureVisible(
          billingContext,
          duration: AppConstants.animationDuration,
        );
      }
      return;
    }
    if (!supportsPaymentWebView) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Payment checkout is available on Android, iOS, and macOS.',
          ),
        ),
      );
      return;
    }
    final controller = ref.read(
      checkoutControllerProvider(widget.draft).notifier,
    );
    var payment = await controller.start(billing);
    if (!mounted) return;
    if (payment == null) {
      await ref
          .read(notificationsControllerProvider.notifier)
          .add(
            type: NotificationType.appointmentCreationFailure,
            title: 'Appointment could not be created',
            message:
                'We could not start your appointment booking. Please try again.',
          );
      return;
    }
    if (!payment.isTerminal && payment.checkoutUrl != null) {
      await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => PaymentCheckoutScreen(
            url: payment!.checkoutUrl!,
            checkStatus: controller.refresh,
          ),
        ),
      );
      if (!mounted) return;
      payment = await controller.refresh();
    }
    if (!mounted || payment == null) return;
    if (payment.isPaid) {
      await ref
          .read(notificationsControllerProvider.notifier)
          .add(
            type: NotificationType.appointmentCreated,
            title: 'Appointment booked',
            message:
                'Your appointment with ${widget.draft.doctor.summary.name} is confirmed.',
            appointmentId: payment.appointmentId,
            remindAt: widget.draft.scheduledAt?.subtract(
              const Duration(minutes: 30),
            ),
          );
      if (!mounted) return;
      context.pushNamed(
        AppRoutes.appointmentConfirmation,
        pathParameters: {'doctorId': widget.draft.doctor.routeId},
        extra: widget.draft,
      );
    } else {
      if (payment.status == 'failed' || payment.status == 'cancelled') {
        await ref
            .read(notificationsControllerProvider.notifier)
            .add(
              type: NotificationType.paymentFailure,
              title: 'Payment failed',
              message: 'Payment for your appointment was ${payment.status}.',
              appointmentId: payment.appointmentId,
            );
      }
      final message = switch (payment.status) {
        'review' => 'Your payment is under review. Please contact support.',
        'failed' => 'Payment failed. Your appointment has not been confirmed.',
        'cancelled' => 'Payment was cancelled.',
        _ =>
          'Payment is still pending. Check status before starting another payment.',
      };
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkout = ref.watch(checkoutControllerProvider(widget.draft));
    final user = ref.watch(authSessionProvider).asData?.value;
    return Scaffold(
      appBar: careAppBar(context, title: const Text('Payment')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Appointment summary',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppointmentSummaryCard(draft: widget.draft),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Payment method',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        for (final method
                            in AppointmentPaymentMethod.values) ...[
                          AppointmentPaymentMethodCard(
                            method: method,
                            selected: widget.draft.paymentMethod == method,
                            onTap: () {
                              if (!checkout.hasStarted) {
                                setState(
                                  () => widget.draft.paymentMethod = method,
                                );
                              }
                            },
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        AppointmentPriceDetails(draft: widget.draft),
                        const SizedBox(height: AppSpacing.lg),
                        PaymentBillingForm(
                          key: _billingKey,
                          enabled: !checkout.hasStarted,
                          name: user?.displayName,
                          email: user?.email,
                          phone: user?.phoneNumber,
                        ),
                        if (checkout.errorMessage != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            checkout.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                AppointmentContinueButton(
                  label: checkout.isLoading || checkout.isCreatingChat
                      ? 'Please wait…'
                      : checkout.payment != null
                      ? 'Resume payment / check status'
                      : 'Pay & confirm',
                  onPressed:
                      !checkout.isLoading &&
                          !checkout.isCreatingChat &&
                          widget.draft.total != null &&
                          widget.draft.scheduledAt?.isAfter(DateTime.now()) ==
                              true
                      ? _pay
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
