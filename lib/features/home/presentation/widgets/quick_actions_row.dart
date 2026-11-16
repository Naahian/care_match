import 'package:care_match/core/constants/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

import 'quick_action.dart';

/// Row of four entry points: Find a Doctor, Chat, Video, My Care.
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Care, your way', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height:
              112 +
              (MediaQuery.textScalerOf(context).scale(12) - 12).clamp(0, 40) *
                  2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: QuickAction(
                  icon: Icons.medical_services_outlined,
                  label: 'Find a\ndoctor',
                  background: const Color(0xFFE4F4EE),
                  foreground: const Color(0xFF299581),
                  onTap: () {
                    context.pushNamed(AppRoutes.doctors);
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: QuickAction(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Chat\nconsult',
                  background: const Color(0xFFE0F2F7),
                  foreground: const Color(0xFF1C91AF),
                  onTap: () {
                    context.pushNamed(AppRoutes.chat);
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: QuickAction(
                  icon: Icons.videocam_outlined,
                  label: 'Video\nconsult',
                  background: const Color(0xFFF6E5EE),
                  foreground: const Color(0xFFD75D90),
                  onTap: () {
                    context.pushNamed(AppRoutes.video);
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: QuickAction(
                  icon: Icons.description_outlined,
                  label: 'My\ncare',
                  background: const Color(0xFFF8EFD9),
                  foreground: const Color(0xFFB18B3A),
                  onTap: () {
                    context.pushNamed(AppRoutes.appointments);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
