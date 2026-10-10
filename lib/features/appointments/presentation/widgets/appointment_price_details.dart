import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';
import '../models/appointment_draft.dart';

class AppointmentPriceDetails extends StatelessWidget {
  const AppointmentPriceDetails({super.key, required this.draft});
  final AppointmentDraft draft;

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    bool total = false,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: total
                ? Theme.of(context).textTheme.titleMedium
                : Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            value,
            style: total
                ? Theme.of(context).textTheme.titleMedium
                : Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('Price details', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: AppSpacing.sm),
      _row(context, 'Consultation fee', draft.priceFor(draft.type)),
      _row(context, 'Service fee', appointmentMoney(draft.serviceFee)),
      const Divider(),
      _row(
        context,
        'Total',
        draft.total == null ? 'Not provided' : appointmentMoney(draft.total!),
        total: true,
      ),
    ],
  );
}
