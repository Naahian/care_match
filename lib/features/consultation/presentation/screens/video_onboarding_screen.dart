import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

import '../widgets/tips_card.dart';
import '../widgets/upcoming_consultation.dart';
import '../widgets/upcoming_consultation_card.dart';
import '../widgets/video_illustration_slot.dart';
import '../widgets/video_title_block.dart';

/// Pre-call "Video Consultation" screen: upcoming session summary,
/// preparation tips and a pinned "Join Consultation" button.
class VideoOnboardingScreen extends StatelessWidget {
  const VideoOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    children: [
                      const VideoIllustrationSlot(),
                      const SizedBox(height: AppSpacing.lg),
                      const VideoTitleBlock(),
                      const SizedBox(height: AppSpacing.lg),
                      UpcomingConsultationCard(
                        consultation: sampleConsultation,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const TipsCard(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        // TODO: navigate to the video call room and join the session
                      },
                      icon: const Icon(Icons.videocam_rounded),
                      label: const Text('Join Consultation'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
