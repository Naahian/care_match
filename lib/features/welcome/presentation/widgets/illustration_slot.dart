import 'package:flutter/material.dart';

/// Displays the welcome artwork within the available page space.
class IllustrationSlot extends StatelessWidget {
  const IllustrationSlot({super.key, required this.imageAsset});

  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 120),
      child: Image.asset(
        imageAsset,
        width: double.infinity,
        height: 120,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      ),
    );
  }
}
