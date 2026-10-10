import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

/// Hero card with the symptom description search field.
class SymptomCard extends StatelessWidget {
  const SymptomCard({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    const noBorder = OutlineInputBorder(
      borderRadius: AppRadius.chip,
      borderSide: BorderSide.none,
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: AppRadius.sheet,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling today?',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Describe your symptoms to get matched with the right doctor.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSubmit(),
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'e.g. headache, sore throat, anxiety...',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              fillColor: scheme.surfaceContainerLowest,
              border: noBorder,
              enabledBorder: noBorder,
              focusedBorder: noBorder,
              prefixIcon: Icon(
                Icons.auto_awesome_rounded,
                color: scheme.primary,
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: IconButton.filled(
                  onPressed: onSubmit,
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                  ),
                  tooltip: 'Search',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
