import 'package:care_match/core/constants/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:care_match/core/constants/constants.dart';
import 'package:care_match/shared/widgets/brand_header.dart';

import 'package:flutter/material.dart';

import '../widgets/chat_illustration_slot.dart';
import '../widgets/chat_title_block.dart';
import '../widgets/conversation.dart';
import '../widgets/conversation_card.dart';
import '../widgets/conversation_section_header.dart';
import '../widgets/find_doctor_banner.dart';

/// "Chat & Video Consult" sub-screen: recent conversations plus a shortcut
/// to find a new doctor.
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const BrandHeader(), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.lg,
              ),
              children: [
                const ChatIllustrationSlot(),
                const SizedBox(height: AppSpacing.lg),
                const ChatTitleBlock(),
                const SizedBox(height: AppSpacing.lg),
                const ConversationSectionHeader(),
                const SizedBox(height: AppSpacing.sm),
                for (var i = 0; i < sampleConversations.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.md),
                  ConversationCard(
                    conversation: sampleConversations[i],
                    onTap: () {
                      context.pushNamed(
                        AppRoutes.conversation,
                        queryParameters: {
                          'doctor': sampleConversations[i].doctorName,
                        },
                      );
                    },
                    onVideoTap: () {
                      context.pushNamed(AppRoutes.video);
                    },
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                FindDoctorBanner(
                  onTap: () {
                    context.pushNamed(AppRoutes.doctors);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
