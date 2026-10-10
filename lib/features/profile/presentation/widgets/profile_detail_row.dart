import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

class ProfileDetailRow extends StatelessWidget {
  const ProfileDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: AppSpacing.card,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(label, style: theme.textTheme.labelLarge)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(value, style: theme.textTheme.bodySmall)),
          ],
        ),
      ),
    );
  }
}
