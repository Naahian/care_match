import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

/// Shared CareMatch logo and wordmark.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/carematch_logo.png',
      width: 192,
      height: 64,
      fit: BoxFit.contain,
      semanticLabel: AppConstants.appName,
    );
  }
}
