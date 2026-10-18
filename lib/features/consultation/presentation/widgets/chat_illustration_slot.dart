import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Hero artwork for chat consultations.
class ChatIllustrationSlot extends StatelessWidget {
  const ChatIllustrationSlot({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/chat_feature.png',
      width: double.infinity,
      height: 16.h.clamp(120.0, 240.0),
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
  }
}
