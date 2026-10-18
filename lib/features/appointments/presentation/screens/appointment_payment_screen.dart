import 'package:care_match/core/constants/constants.dart';
import 'package:care_match/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/appointment_draft.dart';
import '../widgets/appointment_continue_button.dart';
import '../widgets/appointment_summary_card.dart';
import '../widgets/appointment_payment_method_card.dart';
import '../widgets/appointment_price_details.dart';

class AppointmentPaymentScreen extends StatefulWidget {
  const AppointmentPaymentScreen({super.key, required this.draft});
  final AppointmentDraft draft;
  @override
  State<AppointmentPaymentScreen> createState() =>
      _AppointmentPaymentScreenState();
}

class _AppointmentPaymentScreenState extends State<AppointmentPaymentScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Payment'), centerTitle: true),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: AppSpacing.page,
                  children: [
                    Text(
                      'Appointment summary',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppointmentSummaryCard(draft: widget.draft),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Payment method',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    for (final method in AppointmentPaymentMethod.values) ...[
                      AppointmentPaymentMethodCard(
                        method: method,
                        selected: widget.draft.paymentMethod == method,
                        onTap: () {
                          setState(() => widget.draft.paymentMethod = method);
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    AppointmentPriceDetails(draft: widget.draft),
                  ],
                ),
              ),
              AppointmentContinueButton(
                label: 'Pay & confirm',
                onPressed:
                    widget.draft.total != null &&
                        widget.draft.scheduledAt?.isAfter(DateTime.now()) ==
                            true
                    ? () => context.pushNamed(
                        AppRoutes.appointmentConfirmation,
                        pathParameters: {
                          'doctorId': widget.draft.doctor.routeId,
                        },
                        extra: widget.draft,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
