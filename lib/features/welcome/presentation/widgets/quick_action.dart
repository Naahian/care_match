import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

/// Circular icon tile with a label underneath (used in the final page's
/// quick-action row).
class QuickAction extends StatelessWidget {
  const QuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          child: Icon(icon, color: foreground, size: 26),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
