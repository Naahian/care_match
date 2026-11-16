import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/constants.dart';
import '../controllers/checkout_controller.dart';
import '../models/appointment_draft.dart';

class BookingChatStatus extends ConsumerWidget {
  const BookingChatStatus({super.key, required this.draft});
  final AppointmentDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkoutControllerProvider(draft));
    if (state.payment?.isPaid != true) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    state.chatId != null
                        ? 'Your chat is ready'
                        : 'Your appointment is booked',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (state.isCreatingChat) ...[
              const Text('Preparing your conversation…'),
              const SizedBox(height: AppSpacing.sm),
              const LinearProgressIndicator(),
            ] else if (state.chatId case final chatId?)
              TextButton.icon(
                onPressed: () => context.pushNamed(
                  AppRoutes.conversation,
                  queryParameters: {'chatId': chatId},
                ),
                icon: const Icon(Icons.chat_outlined),
                label: const Text('Open chat'),
              )
            else ...[
              const Text(
                'Your payment was successful. Your chat is not ready yet.',
              ),
              if (state.chatErrorMessage case final error?) Text(error),
              TextButton(
                onPressed: () => ref
                    .read(checkoutControllerProvider(draft).notifier)
                    .prepareChat(),
                child: const Text('Retry chat setup'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
