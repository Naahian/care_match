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
    padding: AppSpacing.gutter,
    child: Row(
      children: [
        for (final specialty in ['', ...specialties]) ...[
          ChoiceChip(
            label: Text(specialty.isEmpty ? 'All specialties' : specialty),
            selected: selected == specialty,
            onSelected: (_) => onSelected?.call(specialty),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ],
    ),
  );
}
