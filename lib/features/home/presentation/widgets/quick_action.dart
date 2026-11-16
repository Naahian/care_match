import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

/// Circular icon tile with a label underneath (used in quick-action rows).
class QuickAction extends StatelessWidget {
  const QuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: AppRadius.sheet,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.sheet,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xs,
            12,
            AppSpacing.xs,
            10,
          ),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: AppRadius.card,
                ),
                child: Icon(icon, color: foreground, size: 24),
              ),
              const Spacer(),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
