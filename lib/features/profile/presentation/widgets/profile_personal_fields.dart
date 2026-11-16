import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../domain/entities/profile_update.dart';

class ProfilePersonalFields extends StatelessWidget {
  const ProfilePersonalFields({
    super.key,
    required this.birth,
    required this.dateOfBirth,
    required this.gender,
    required this.bloodGroup,
    required this.enabled,
    required this.onPickBirth,
    required this.onClearBirth,
    required this.onGenderChanged,
    required this.onBloodGroupChanged,
  });

  final TextEditingController birth;
  final DateTime? dateOfBirth;
  final String? gender, bloodGroup;
  final bool enabled;
  final VoidCallback onPickBirth, onClearBirth;
  final ValueChanged<String?> onGenderChanged, onBloodGroupChanged;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      TextFormField(
        controller: birth,
        enabled: enabled,
        readOnly: true,
        onTap: onPickBirth,
        validator: (_) => ProfileUpdate.validateDateOfBirth(dateOfBirth),
        decoration: InputDecoration(
          labelText: 'Date of birth',
          hintText: 'Select date of birth',
          prefixIcon: const Icon(Icons.calendar_month_outlined),
          suffixIcon: dateOfBirth == null
              ? null
              : IconButton(
                  tooltip: 'Clear date of birth',
                  onPressed: enabled ? onClearBirth : null,
                  icon: const Icon(Icons.clear),
                ),
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      _selection(
        label: 'Gender',
        value: gender,
        options: ProfileUpdate.genders,
        onChanged: onGenderChanged,
      ),
      const SizedBox(height: AppSpacing.md),
      _selection(
        label: 'Blood group',
        value: bloodGroup,
        options: ProfileUpdate.bloodGroups,
        onChanged: onBloodGroupChanged,
      ),
    ],
  );

  Widget _selection({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) => DropdownButtonFormField<String>(
    key: ValueKey('$label:$value'),
    initialValue: value ?? '',
    isExpanded: true,
    decoration: InputDecoration(labelText: label),
    items: [
      const DropdownMenuItem(value: '', child: Text('Not specified')),
      for (final option in {...options, ?value})
        DropdownMenuItem(value: option, child: Text(option)),
    ],
    onChanged: enabled
        ? (selection) => onChanged(selection == '' ? null : selection)
        : null,
  );
}
