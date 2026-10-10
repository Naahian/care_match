import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Circular specialty shortcut with a label underneath.
class SpecialtyItem extends StatelessWidget {
  const SpecialtyItem({
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
    final circle = 15.w.clamp(52.0, 72.0);

    return SizedBox(
      width: 21.w.clamp(76.0, 100.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Column(
          children: [
            Container(
              width: circle,
              height: circle,
              decoration: BoxDecoration(
                color: background,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: foreground, size: 22.sp),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
