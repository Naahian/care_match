import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.roundedRectangle = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool roundedRectangle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = roundedRectangle ? AppRadius.card : AppRadius.chip;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: roundedRectangle
            ? null
            : LinearGradient(colors: [scheme.tertiary, scheme.primary]),
      ),
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: roundedRectangle
              ? scheme.primary
              : Colors.transparent,
          disabledBackgroundColor: scheme.surfaceContainerHighest,
          minimumSize: const Size(0, 52),
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: radius),
          padding: const EdgeInsets.all(AppSpacing.md),
        ),
        onPressed: isLoading ? null : onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(child: Text(label, textAlign: TextAlign.center)),
            const SizedBox(width: AppSpacing.sm),
            if (isLoading)
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: scheme.onSurfaceVariant,
                ),
              )
            else
              const Icon(Icons.arrow_forward_rounded),
          ],
        ),
      ),
    );
  }
}
