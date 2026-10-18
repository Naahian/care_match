import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/widgets/doctor_avatar.dart';
import '../models/chat_message.dart';
import '../widgets/chat_composer.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/conversation.dart';

/// A demo chat thread. Messages are kept locally while this screen is open.
class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key, required this.conversation});

  final Conversation conversation;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _composer = TextEditingController();
  final _scrollController = ScrollController();
  late final List<ChatMessage> _messages = [
    const ChatMessage(
      text: 'Hello! Welcome to your follow-up consultation. How are you today?',
      time: '10:18 AM',
    ),
    const ChatMessage(
      text: 'Hello, doctor. Thank you for checking in.',
      time: '10:20 AM',
      isFromPatient: true,
    ),
    const ChatMessage(
      text: 'I have a few questions about our last consultation.',
      time: '10:21 AM',
      isFromPatient: true,
    ),
    ChatMessage(text: widget.conversation.lastMessage, time: '10:24 AM'),
  ];

  void _sendMessage() {
    final text = _composer.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          time: TimeOfDay.now().format(context),
          isFromPatient: true,
        ),
      );
    });
    _composer.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        0,
        duration: AppConstants.animationDuration,
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _composer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation'),
        actions: [
          IconButton(
            tooltip: 'Start video consult',
            onPressed: () => context.pushNamed(AppRoutes.video),
            icon: const Icon(Icons.videocam_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                _buildDoctorHeader(context),
                const Divider(),
                Padding(
                  padding: AppSpacing.page,
                  child: Text(
                    'Demo conversation • Messages stay on this screen only',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    controller: _scrollController,
                    reverse: true,
                    padding: AppSpacing.page,
                    itemCount: _messages.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, index) => ChatMessageBubble(
                      message: _messages[_messages.length - 1 - index],
                    ),
                  ),
                ),
                const Divider(),
                ChatComposer(controller: _composer, onSend: _sendMessage),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorHeader(BuildContext context) {
    final theme = Theme.of(context);
    final conversation = widget.conversation;
    return Padding(
      padding: AppSpacing.page,
      child: Row(
        children: [
          DoctorAvatar(
            doctorName: conversation.doctorName,
            radius: 7.w.clamp(24.0, 32.0),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.doctorName,
                  style: theme.textTheme.titleMedium,
                ),
                Text(conversation.specialty, style: theme.textTheme.bodySmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  conversation.isOnline ? 'Online now' : 'Currently offline',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: conversation.isOnline
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
