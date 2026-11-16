import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../domain/entities/profile_update.dart';

class ProfileEditFields extends StatelessWidget {
  const ProfileEditFields({
    super.key,
    required this.name,
    required this.phone,
    required this.enabled,
  });

  final TextEditingController name, phone;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      TextFormField(
        controller: name,
        enabled: enabled,
        maxLength: 128,
        textCapitalization: TextCapitalization.words,
        autofillHints: const [AutofillHints.name],
        textInputAction: TextInputAction.next,
        validator: ProfileUpdate.validateName,
        decoration: const InputDecoration(labelText: 'Name'),
      ),
      const SizedBox(height: AppSpacing.md),
      TextFormField(
        controller: phone,
        enabled: enabled,
        maxLength: 20,
        keyboardType: TextInputType.phone,
        autofillHints: const [AutofillHints.telephoneNumber],
        textInputAction: TextInputAction.next,
        validator: ProfileUpdate.validatePhone,
        decoration: const InputDecoration(
          labelText: 'Phone number',
          hintText: '+8801712345678',
          helperText: 'Include the country code. Leave blank to remove.',
          helperMaxLines: 2,
        ),
      ),
    ],
  );
}
