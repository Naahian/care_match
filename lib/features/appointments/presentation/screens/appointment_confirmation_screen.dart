import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:care_match/core/constants/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../models/appointment_draft.dart';
import '../widgets/appointment_continue_button.dart';
import '../widgets/appointment_summary_card.dart';

class AppointmentConfirmationScreen extends StatelessWidget {
  const AppointmentConfirmationScreen({super.key, required this.draft});
  final AppointmentDraft draft;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(''), centerTitle: true),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: AppSpacing.page,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    Image.asset(
                      'assets/images/done_hero.png',
                      height: 20.h.clamp(120.0, 220.0),
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
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
                      'You’ll receive a confirmation email shortly.\nA reminder will be sent 30 minutes before your appointment.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppointmentSummaryCard(draft: draft),
                    const SizedBox(height: AppSpacing.sm),
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
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
            ],
          ),
        ),
      ),
    ),
  );
}
