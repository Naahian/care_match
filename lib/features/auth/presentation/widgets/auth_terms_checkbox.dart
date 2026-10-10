import 'package:flutter/material.dart';

class AuthTermsCheckbox extends StatelessWidget {
  const AuthTermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Checkbox(
        value: value,
        onChanged: onChanged,
        semanticLabel: 'Agree to Terms of Service and Privacy Policy',
      ),
      Expanded(
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('I agree to the '),
            TextButton(
              onPressed: () {
                // TODO: route to Terms of Service.
              },
              child: const Text('Terms of Service'),
            ),
            const Text('and '),
            TextButton(
              onPressed: () {
                // TODO: route to Privacy Policy.
              },
              child: const Text('Privacy Policy'),
            ),
          ],
        ),
      ),
    ],
  );
}
