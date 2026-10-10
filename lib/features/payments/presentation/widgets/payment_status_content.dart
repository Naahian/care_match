import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';

class PaymentStatusContent extends StatelessWidget {
  const PaymentStatusContent({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.isError = false,
    this.details,
    this.secondaryAction,
    this.busy = false,
  });
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback? onAction;
  final bool isError;
  final Widget? details;
  final Widget? secondaryAction;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: AppSpacing.page,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: isError
                        ? scheme.errorContainer
                        : scheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 60,
                    color: isError ? scheme.error : scheme.secondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (details != null) ...[
                details!,
                const SizedBox(height: AppSpacing.lg),
              ],
              FilledButton(
                onPressed: busy ? null : onAction,
                child: busy
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(actionLabel),
              ),
              if (secondaryAction != null) ...[
                const SizedBox(height: AppSpacing.sm),
                secondaryAction!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
