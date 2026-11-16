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
        color: selected
            ? Color.alphaBlend(
                scheme.primary.withValues(alpha: .12),
                scheme.surface,
              )
            : scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact =
                    constraints.maxWidth < 265 ||
                    MediaQuery.textScalerOf(context).scale(14) > 18;
                final leading = Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: type == ConsultationType.video
                        ? scheme.errorContainer
                        : type == ConsultationType.chat
                        ? scheme.primaryContainer
                        : scheme.secondaryContainer,
                    borderRadius: AppRadius.button,
                  ),
                  child: Icon(type.icon, color: scheme.primary),
                );
                final details = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(type.description, style: theme.textTheme.bodySmall),
                  ],
                );
                final selection = Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? scheme.primary : scheme.outline,
                );
                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          leading,
                          const SizedBox(width: AppSpacing.md),
                          Expanded(child: details),
                          selection,
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          price,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: scheme.primary,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    leading,
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: details),
                    Text(
                      price,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    selection,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
