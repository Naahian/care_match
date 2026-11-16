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

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            Color.lerp(scheme.primary, scheme.tertiary, .16)!,
          ],
        ),
        borderRadius: AppRadius.sheet,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CARE THAT STARTS WITH YOU',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: .5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'How are you feeling today?',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.smart_toy_rounded,
                size: 56,
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Describe your symptoms to get matched with the right doctor.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: .9),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            height: 48,
            padding: const EdgeInsets.only(left: AppSpacing.md, right: 4),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: AppRadius.input,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: scheme.primary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: controller,
                    //        textInputAction: TextInputAction.search,
                    onSubmitted: (_) => onSubmit(),
                    textAlignVertical: TextAlignVertical.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      hintText: 'e.g. headache, sore throat...',
                      hintStyle: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Material(
                  color: scheme.primaryContainer,
                  borderRadius: AppRadius.input,
                  child: InkWell(
                    borderRadius: AppRadius.input,
                    onTap: onSubmit,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: scheme.primary,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
