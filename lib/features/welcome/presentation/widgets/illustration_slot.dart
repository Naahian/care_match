import 'package:flutter/material.dart';
import 'package:care_match/core/constants/constants.dart';

/// Displays the welcome artwork within the available page space.
class IllustrationSlot extends StatelessWidget {
  const IllustrationSlot({
    super.key,
    required this.imageAsset,
    this.illustration,
  });

  final String imageAsset;
  final Widget? illustration;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 308, maxHeight: 308),
        child: AspectRatio(
          aspectRatio: 1,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child:
                illustration ??
                Image.asset(
                  imageAsset,
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
          ),
        ),
      ),
    );
  }
}
