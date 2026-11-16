import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

import 'page_dots.dart';

/// Pages 1–3: dots above a full-width "Next" button.
class StandardControls extends StatelessWidget {
  const StandardControls({
    super.key,
    required this.index,
    required this.count,
    required this.onNext,
  });

  final int index;
  final int count;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PageDots(index: index, count: count),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onNext,
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 56),
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 20),
                Expanded(child: Text('Next', textAlign: TextAlign.center)),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
