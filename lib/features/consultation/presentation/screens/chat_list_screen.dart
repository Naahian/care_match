import 'package:care_match/shared/widgets/care_app_bar.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../providers.dart';
import '../controllers/chat_list_controller.dart';
import '../widgets/chat_illustration_slot.dart';
import '../widgets/chat_title_block.dart';
import '../widgets/conversation.dart';
import '../widgets/conversation_card.dart';
import '../widgets/conversation_card_shimmer.dart';
import '../widgets/conversation_section_header.dart';
import '../widgets/find_doctor_banner.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key, this.recipientUid});
  final String? recipientUid;
  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.listenManual(consultationUserProvider, (_, uid) {
      scheduleMicrotask(() async {
        if (!mounted || ref.read(consultationUserProvider) != uid) return;
        final controller = ref.read(chatListControllerProvider.notifier);
        unawaited(controller.load());
        final recipient = widget.recipientUid;
        if (uid != null && recipient != null) {
          final chat = await controller.startChat(recipient);
          if (mounted &&
              chat != null &&
              ref.read(consultationUserProvider) == uid) {
            await context.pushNamed(
              AppRoutes.conversation,
              queryParameters: {'chatId': chat.id},
            );
          }
        }
      });
    }, fireImmediately: true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(chatListControllerProvider.notifier).load());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatListControllerProvider);
    final uid = ref.watch(consultationUserProvider);
    final profiles = uid == null
        ? null
        : ref.watch(consultationDoctorsProvider).asData?.value;
    final controller = ref.read(chatListControllerProvider.notifier);
    return Scaffold(
      appBar: careAppBar(context),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: RefreshIndicator(
              onRefresh: () => controller.load(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  const ChatTitleBlock(),
                  const SizedBox(height: AppSpacing.xl),
                  const ChatIllustrationSlot(),
                  const SizedBox(height: AppSpacing.lg),
                  const ConversationSectionHeader(),
                  const SizedBox(height: AppSpacing.md),
                  if (state.isLoading || state.isCreating)
                    for (var i = 0; i < (state.chats.isEmpty ? 3 : 1); i++) ...[
                      const ConversationCardShimmer(),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  if (state.error case final error?) ...[
                    Text(error),
                    if (uid != null)
                      TextButton(
                        onPressed: () async {
                          await controller.load();
                          if (!context.mounted ||
                              ref.read(consultationUserProvider) != uid) {
                            return;
                          }
                          if (widget.recipientUid case final recipient?) {
                            final chat = await controller.startChat(recipient);
                            if (context.mounted &&
                                chat != null &&
                                ref.read(consultationUserProvider) == uid) {
                              context.pushNamed(
                                AppRoutes.conversation,
                                queryParameters: {'chatId': chat.id},
                              );
                            }
                          }
                        },
                        child: const Text('Retry'),
                      ),
                  ],
                  if (state.liveError case final error?) ...[
                    Text(error),
                    TextButton(
                      onPressed: () => controller.load(),
                      child: const Text('Reconnect'),
                    ),
                  ],
                  if (state.hasLoaded &&
                      state.chats.isEmpty &&
                      !state.isLoading)
                    const EmptyState(
                      icon: Icons.chat_bubble_outline_rounded,
                      message: 'No conversations yet',
                    ),
                  for (final chat in state.chats) ...[
                    Builder(
                      builder: (context) {
                        final peerId = chat.otherParticipant(uid!);
                        final profile = profiles?[peerId];
                        return ConversationCard(
                          conversation: Conversation(
                            peerName: profile?.name ?? 'Conversation',
                            photoUrl: profile?.photoUrl,
                            specialty: profile?.specialties.join(', ') ?? '',
                            lastMessage:
                                chat.lastMessage?.text ??
                                'Start a conversation',
                            time: MaterialLocalizations.of(
                              context,
                            ).formatShortDate(chat.updatedAt.toLocal()),
                          ),
                          onTap: () async {
                            await context.pushNamed(
                              AppRoutes.conversation,
                              queryParameters: {'chatId': chat.id},
                            );
                            if (mounted) unawaited(controller.load());
                          },
                          onVideoTap: () => context.pushNamed(AppRoutes.video),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  if (state.isLoadingMore) ...[
                    const ConversationCardShimmer(),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  if (state.nextCursor != null)
                    TextButton(
                      onPressed: state.isLoadingMore
                          ? null
                          : () => controller.load(more: true),
                      child: Text(
                        state.isLoadingMore
                            ? 'Loading…'
                            : 'Load more conversations',
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  FindDoctorBanner(
                    onTap: () => context.pushNamed(AppRoutes.doctors),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
