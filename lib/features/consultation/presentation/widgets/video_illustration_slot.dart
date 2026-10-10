import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Hero artwork for video consultation onboarding.
class VideoIllustrationSlot extends StatelessWidget {
  const VideoIllustrationSlot({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/welcome_1.png',
      width: double.infinity,
      height: 24.h.clamp(150.0, 240.0),
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
  }
}
