import 'package:care_match/core/constants/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:care_match/core/constants/constants.dart';
import 'package:care_match/core/theme/theme.dart';
import 'package:flutter/material.dart';

import 'quick_action.dart';

/// Row of four entry points: Find a Doctor, Chat, Video, My Care.
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final extras = Theme.of(context).extension<AppExtras>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: QuickAction(
            icon: Icons.medical_services_outlined,
            label: 'Find a Doctor',
            background: scheme.primaryContainer,
            foreground: scheme.primary,
            onTap: () {
              context.pushNamed(AppRoutes.doctors);
            },
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: QuickAction(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Chat Consult',
            background: scheme.secondaryContainer,
            foreground: scheme.onSecondaryContainer,
            onTap: () {
              context.pushNamed(AppRoutes.chat);
            },
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: QuickAction(
            icon: Icons.videocam_outlined,
            label: 'Video Consult',
            background: scheme.tertiaryContainer,
            foreground: scheme.onTertiaryContainer,
            onTap: () {
              context.pushNamed(AppRoutes.video);
            },
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: QuickAction(
            icon: Icons.description_outlined,
            label: 'My Care',
            background: extras.warningContainer,
            foreground: extras.warning,
            onTap: () {
              context.pushNamed(AppRoutes.appointments);
            },
          ),
        ),
        SizedBox(width: AppSpacing.sm),
      ],
    );
  }
}
