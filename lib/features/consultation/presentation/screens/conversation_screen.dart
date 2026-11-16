import 'dart:async';

import 'package:care_match/shared/widgets/care_app_bar.dart';
import 'package:care_match/shared/widgets/doctor_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../providers.dart';
import '../controllers/conversation_controller.dart';
import '../models/chat_message.dart';
import '../widgets/chat_composer.dart';
import '../widgets/chat_message_bubble.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key, required this.chatId});
  final String chatId;
  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen>
    with WidgetsBindingObserver {
  final _composer = TextEditingController();
  final _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.listenManual(consultationUserProvider, (_, uid) {
      _composer.clear();
      scheduleMicrotask(() {
        if (mounted && ref.read(consultationUserProvider) == uid) {
          unawaited(
            ref
                .read(conversationControllerProvider(widget.chatId).notifier)
                .open(),
          );
        }
      });
    }, fireImmediately: true);
  }

  @override
  void didUpdateWidget(covariant ConversationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chatId != widget.chatId) {
      _composer.clear();
      scheduleMicrotask(() {
        if (mounted) {
          unawaited(
            ref
                .read(conversationControllerProvider(widget.chatId).notifier)
                .open(),
          );
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(
        ref.read(conversationControllerProvider(widget.chatId).notifier).open(),
      );
    }
  }

  Future<void> _send() async {
    final text = _composer.text;
    final chatId = widget.chatId;
    final uid = ref.read(consultationUserProvider);
    final controller = ref.read(
      conversationControllerProvider(widget.chatId).notifier,
    );
    if (await controller.send(text)) {
      if (!mounted ||
          widget.chatId != chatId ||
          ref.read(consultationUserProvider) != uid) {
        return;
      }
      if (_composer.text == text) _composer.clear();
      if (_scrollController.hasClients) {
        unawaited(
          _scrollController.animateTo(
            0,
            duration: AppConstants.animationDuration,
            curve: Curves.easeOut,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _composer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationControllerProvider(widget.chatId));
    final controller = ref.read(
      conversationControllerProvider(widget.chatId).notifier,
    );
    final uid = ref.watch(consultationUserProvider);
    final profiles = uid == null
        ? null
        : ref.watch(consultationDoctorsProvider).asData?.value;
    final peer = state.chat == null || uid == null
        ? null
        : profiles?[state.chat!.otherParticipant(uid)];
    return Scaffold(
      appBar: careAppBar(
        context,
        title: Row(
          children: [
            DoctorAvatar(
              doctorName: peer?.name ?? 'Conversation',
              photoUrl: peer?.photoUrl,
              radius: 21,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    peer?.name ?? 'Conversation',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Chat consultation',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                if (state.isLoading) const LinearProgressIndicator(),
                if (state.error case final error?)
                  Padding(
                    padding: AppSpacing.gutter,
                    child: Column(
                      children: [
                        Text(error),
                        if (uid != null)
                          TextButton(
                            onPressed: controller.open,
                            child: const Text('Retry'),
                          ),
                      ],
                    ),
                  ),
                if (state.liveError case final error?)
                  Padding(
                    padding: AppSpacing.gutter,
                    child: Column(
                      children: [
                        Text(error),
                        TextButton(
                          onPressed: controller.open,
                          child: const Text('Reconnect'),
                        ),
                      ],
                    ),
                  ),
                if (state.nextCursor != null)
                  TextButton(
                    onPressed: state.isLoadingMore
                        ? null
                        : controller.loadOlder,
                    child: Text(
                      state.isLoadingMore ? 'Loading…' : 'Load older messages',
                    ),
                  ),
                Expanded(
                  child: state.messages.isEmpty
                      ? state.hasLoaded
                            ? const SingleChildScrollView(
                                child: EmptyState(
                                  icon: Icons.chat_bubble_outline_rounded,
                                  message: 'No messages yet. Say hello!',
                                ),
                              )
                            : const SizedBox.shrink()
                      : ListView.separated(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          itemCount: state.messages.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) {
                            final message = state.messages[index];
                            final date = message.createdAt.toLocal();
                            final older = index + 1 < state.messages.length
                                ? state.messages[index + 1].createdAt.toLocal()
                                : null;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (!DateUtils.isSameDay(date, older))
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppSpacing.md,
                                    ),
                                    child: Text(
                                      MaterialLocalizations.of(
                                        context,
                                      ).formatShortDate(date),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ),
                                ChatMessageBubble(
                                  message: ChatMessage(
                                    text: message.text,
                                    time: TimeOfDay.fromDateTime(
                                      date,
                                    ).format(context),
                                    isMine: message.senderUid == uid,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
                if (state.sendError case final error?)
                  Padding(
                    padding: AppSpacing.gutter,
                    child: Text(
                      '$error${state.pending == null ? '' : ' Retry sending the same message.'}',
                    ),
                  ),
                ChatComposer(
                  controller: _composer,
                  onSend: _send,
                  enabled:
                      state.chat != null &&
                      uid != null &&
                      !state.isLoading &&
                      !state.isSending,
                  readOnly: state.isSending || state.pending != null,
                  isSending: state.isSending,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
