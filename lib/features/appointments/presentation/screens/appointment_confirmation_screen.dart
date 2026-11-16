import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:care_match/core/constants/app_routes.dart';
import 'package:go_router/go_router.dart';
import '../models/appointment_draft.dart';
import '../widgets/appointment_continue_button.dart';
import '../widgets/appointment_summary_card.dart';
import '../widgets/booking_chat_status.dart';

class AppointmentConfirmationScreen extends StatelessWidget {
  const AppointmentConfirmationScreen({super.key, required this.draft});
  final AppointmentDraft draft;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: AppRadius.button,
                          ),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Booking complete',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSecondaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Your appointment is booked!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'You’ll receive a confirmation email shortly.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppointmentSummaryCard(draft: draft),
                    if (draft.type == ConsultationType.chat) ...[
                      const SizedBox(height: AppSpacing.md),
                      BookingChatStatus(draft: draft),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Card(
                      color: Color.alphaBlend(
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: .10),
                        Theme.of(context).colorScheme.surface,
                      ),
                      child: Padding(
                        padding: AppSpacing.card,
                        child: Row(
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            const Expanded(
                              child: Text(
                                'A reminder will be sent 30 minutes before your appointment.',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppointmentContinueButton(
                label: 'View appointment',
                onPressed: () {
                  context.goNamed(AppRoutes.appointments, extra: draft);
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.goNamed(AppRoutes.home),
                    icon: const Icon(Icons.home_outlined),
                    label: const Text('Back to home'),
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
