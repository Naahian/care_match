import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';

class ProfilePhotoField extends StatelessWidget {
  const ProfilePhotoField({
    super.key,
    this.bytes,
    this.photoUrl,
    required this.enabled,
    required this.isPicking,
    required this.isRemoved,
    required this.onPick,
    required this.onRemove,
    this.error,
  });

  final Uint8List? bytes;
  final String? photoUrl;
  final bool enabled, isPicking, isRemoved;
  final VoidCallback onPick, onRemove;
  final String? error;

  @override
  Widget build(BuildContext context) {
    const placeholder = Icon(Icons.person_outline, size: 48);
    final image = bytes != null
        ? Image.memory(
            bytes!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => placeholder,
          )
        : !isRemoved && photoUrl != null
        ? Image.network(
            photoUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => placeholder,
          )
        : placeholder;
    return Column(
      children: [
        const Text('Profile photo'),
        const SizedBox(height: AppSpacing.sm),
        ClipOval(child: SizedBox.square(dimension: 96, child: image)),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.sm,
          children: [
            TextButton.icon(
              onPressed: enabled ? onPick : null,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(isPicking ? 'Opening photos…' : 'Choose photo'),
            ),
            if (bytes != null || photoUrl != null || isRemoved)
              TextButton(
                onPressed: enabled ? onRemove : null,
                child: Text(isRemoved ? 'Keep current photo' : 'Remove photo'),
              ),
          ],
        ),
        if (error != null)
          Text(
            error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    );
  }
}
