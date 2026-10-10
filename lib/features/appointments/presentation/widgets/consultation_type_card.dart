import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';
import '../models/appointment_draft.dart';

class ConsultationTypeCard extends StatelessWidget {
  const ConsultationTypeCard({
    super.key,
    required this.type,
    required this.price,
    required this.selected,
    required this.onTap,
  });
  final ConsultationType type;
  final String price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      selected: selected,
      button: true,
      child: Card(
        color: selected ? scheme.primaryContainer : scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(
            color: selected ? scheme.primary : scheme.outlineVariant,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: AppSpacing.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(type.icon, color: scheme.primary, size: 28),
                    Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: selected ? scheme.primary : scheme.outline,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  type.label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(type.description, style: theme.textTheme.bodySmall),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  price,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
