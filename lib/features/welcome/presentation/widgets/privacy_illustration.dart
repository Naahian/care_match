import 'package:flutter/material.dart';

/// Shows the center of the existing artwork, excluding its privacy badges.
class PrivacyIllustration extends StatelessWidget {
  const PrivacyIllustration({super.key, required this.imageAsset});

  final String imageAsset;

  @override
  Widget build(BuildContext context) => FittedBox(
    child: ClipRect(
      child: Align(
        heightFactor: .36,
        child: Image.asset(
          imageAsset,
          width: 1086,
          height: 1448,
          fit: BoxFit.fill,
          excludeFromSemantics: true,
        ),
      ),
    ),
  );
}
