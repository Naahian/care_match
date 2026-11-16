import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';
import '../models/appointment_draft.dart';

class AppointmentPaymentMethodCard extends StatelessWidget {
  const AppointmentPaymentMethodCard({
    super.key,
    required this.method,
    required this.selected,
    required this.onTap,
  });
  final AppointmentPaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      button: true,
      child: Card(
        color: selected
            ? Color.alphaBlend(
                scheme.primary.withValues(alpha: .12),
                scheme.surface,
              )
            : scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          leading: Icon(
            method == AppointmentPaymentMethod.sslcommerz
                ? Icons.payment_rounded
                : Icons.account_balance_wallet_outlined,
            color: scheme.primary,
          ),
          title: Text(method.label),
          trailing: Icon(
            selected
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_unchecked_rounded,
            color: selected ? scheme.primary : scheme.outline,
          ),
        ),
      ),
    );
  }
}
