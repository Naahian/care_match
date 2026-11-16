import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/theme_extensions.dart';

class PracticeActionCard extends StatelessWidget {
  const PracticeActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.secondary = false,
  });
  final String title, subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final extras = theme.extension<AppExtras>();
    final color = secondary
        ? scheme.secondary
        : extras?.warning ?? scheme.tertiary;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: secondary
                          ? scheme.secondaryContainer
                          : extras?.warningContainer ??
                                scheme.tertiaryContainer,
                      borderRadius: AppRadius.button,
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: scheme.primary),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(subtitle, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
