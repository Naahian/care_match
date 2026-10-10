import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'specialty_item.dart';

/// Horizontally scrolling list of specialty shortcuts.
class SpecialtyStrip extends StatelessWidget {
  const SpecialtyStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final items = <SpecialtyItem>[
      SpecialtyItem(
        icon: Icons.people_outline_rounded,
        label: 'General Medicine',
        background: scheme.primaryContainer,
        foreground: scheme.primary,
        onTap: () {
          // TODO: navigate to the General Medicine doctors list
        },
      ),
      SpecialtyItem(
        icon: Icons.face_retouching_natural_outlined,
        label: 'Dermatology',
        background: scheme.secondaryContainer,
        foreground: scheme.onSecondaryContainer,
        onTap: () {
          // TODO: navigate to the Dermatology doctors list
        },
      ),
      SpecialtyItem(
        icon: Icons.child_care_rounded,
        label: 'Pediatrics',
        background: scheme.errorContainer,
        foreground: scheme.onErrorContainer,
        onTap: () {
          // TODO: navigate to the Pediatrics doctors list
        },
      ),
      SpecialtyItem(
        icon: Icons.pregnant_woman_rounded,
        label: 'Gynecology',
        background: scheme.tertiaryContainer,
        foreground: scheme.onTertiaryContainer,
        onTap: () {
          // TODO: navigate to the Gynecology doctors list
        },
      ),
      SpecialtyItem(
        icon: Icons.more_horiz_rounded,
        label: 'More',
        background: scheme.surfaceContainerHigh,
        foreground: scheme.onSurfaceVariant,
        onTap: () {
          // TODO: navigate to the all-specialties screen
        },
      ),
    ];

    return SizedBox(
      height: 15.h.clamp(116.0, 150.0),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, i) => items[i],
      ),
    );
  }
}
