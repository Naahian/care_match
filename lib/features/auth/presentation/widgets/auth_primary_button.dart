import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.chip,
        gradient: LinearGradient(colors: [scheme.tertiary, scheme.primary]),
      ),
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: scheme.surfaceContainerHighest,
          foregroundColor: scheme.onPrimary,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.chip),
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
