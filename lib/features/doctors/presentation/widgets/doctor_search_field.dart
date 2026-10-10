import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

/// Symptom/specialty search input with a leading search icon and a trailing
/// filters button.
class DoctorSearchField extends StatelessWidget {
  const DoctorSearchField({
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

    const pillBorder = OutlineInputBorder(
      borderRadius: AppRadius.chip,
      borderSide: BorderSide.none,
    );

    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => onSubmit(),
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: 'e.g. medecine, ent...',
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        fillColor: scheme.surfaceContainerLowest,
        border: pillBorder,
        enabledBorder: pillBorder.copyWith(
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: pillBorder.copyWith(
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        prefixIcon: Icon(Icons.search_rounded, color: scheme.primary),
      ),
    );
  }
}
