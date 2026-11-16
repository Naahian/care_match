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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            minimumSize: const Size(64, 56),
            backgroundColor: scheme.primary,
            disabledBackgroundColor: Color.alphaBlend(
              scheme.onSurface.withValues(alpha: .08),
              Theme.of(context).scaffoldBackgroundColor,
            ),
            disabledForegroundColor: scheme.onSurfaceVariant,
            foregroundColor: scheme.onPrimary,
            padding: const EdgeInsets.all(AppSpacing.md),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(label, textAlign: TextAlign.start)),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.arrow_forward_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
