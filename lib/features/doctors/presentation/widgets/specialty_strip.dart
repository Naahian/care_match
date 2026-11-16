import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';

class SpecialtyStrip extends StatelessWidget {
  const SpecialtyStrip({
    super.key,
    this.specialties = const [],
    this.selected = '',
    this.onSelected,
  });
  final List<String> specialties;
  final String selected;
  final ValueChanged<String>? onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    child: Row(
      children: [
        for (final specialty in ['', ...specialties]) ...[
          ChoiceChip(
            label: Text(specialty.isEmpty ? 'All specialties' : specialty),
            selected: selected == specialty,
            selectedColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.surface,
            labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: selected == specialty
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            side: BorderSide.none,
            showCheckmark: false,
            labelPadding: const EdgeInsets.symmetric(horizontal: 12),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
            onSelected: (_) => onSelected?.call(specialty),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ],
    ),
  );
}
