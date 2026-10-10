import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';

class PortalStatCard extends StatelessWidget {
  const PortalStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.green = false,
    this.onTap,
  });
  final IconData icon;
  final String value;
  final String label;
  final bool green;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.card,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: green
                    ? scheme.secondaryContainer
                    : scheme.primaryContainer,
                child: Icon(
                  icon,
                  color: green ? scheme.secondary : scheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: green
                            ? scheme.secondary
                            : scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(label, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
