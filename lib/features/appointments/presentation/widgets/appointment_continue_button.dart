import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

class AppointmentContinueButton extends StatelessWidget {
  const AppointmentContinueButton({
    super.key,
    required this.label,
    required this.onPressed,
  });
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: AppSpacing.page,
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: AppRadius.chip,
            gradient: LinearGradient(colors: [scheme.primary, scheme.tertiary]),
          ),
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: scheme.surfaceContainerHighest,
              foregroundColor: scheme.onPrimary,
              padding: const EdgeInsets.all(AppSpacing.md),
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.chip),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(child: Text(label, textAlign: TextAlign.center)),
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.arrow_forward_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
