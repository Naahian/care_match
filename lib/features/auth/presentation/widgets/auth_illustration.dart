import 'package:flutter/material.dart';

class AuthIllustration extends StatelessWidget {
  const AuthIllustration({super.key, required this.asset, this.height = 156});

  final String asset;
  final double height;

  @override
  Widget build(BuildContext context) => Image.asset(
    asset,
    height: height,
    width: double.infinity,
    fit: BoxFit.contain,
    excludeFromSemantics: true,
  );
}
