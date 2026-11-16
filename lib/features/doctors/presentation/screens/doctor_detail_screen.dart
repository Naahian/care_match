import 'package:care_match/core/constants/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';
import '../widgets/doctor_profile.dart';
import '../widgets/doctor_profile_header.dart';
import '../widgets/doctor_profile_facts.dart';
import '../widgets/doctor_consultation_option.dart';
import 'package:care_match/features/appointments/presentation/models/appointment_draft.dart';

class DoctorDetailScreen extends StatefulWidget {
  const DoctorDetailScreen({super.key, required this.profile, this.portrait});
  final DoctorProfile profile;
  final Widget? portrait;

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  void _bookAppointment(ConsultationType type) {
    context.pushNamed(
      AppRoutes.bookAppointment,
      pathParameters: {'doctorId': widget.profile.routeId},
      extra: AppointmentDraft(doctor: widget.profile)..type = type,
    );
  }

  Widget _availabilityPanel(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final days = widget.profile.daysAvailable;
    final label = days.length == 7
        ? 'Monday – Sunday'
        : widget.profile.summary.availability;
    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            if (days.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 5,
                runSpacing: AppSpacing.sm,
                children: days
                    .map(
                      (day) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.secondaryContainer,
                          borderRadius: AppRadius.button,
                        ),
                        child: Text(
                          day.length > 3 ? day.substring(0, 3) : day,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: scheme.onSecondaryContainer),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor profile', style: theme.textTheme.titleMedium),
        leadingWidth: 66,
        leading: Navigator.of(context).canPop()
            ? Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Center(
                  child: IconButton.filled(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).backButtonTooltip,
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: IconButton.styleFrom(
                      backgroundColor: scheme.surface,
                      foregroundColor: scheme.onSurface,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.card,
                      ),
                    ),
                    icon: const Icon(Icons.arrow_back, size: 20),
                  ),
                ),
              )
            : null,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    children: [
                      DoctorProfileHeader(
                        profile: widget.profile,
                        portrait: widget.portrait,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Practice details',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DoctorProfileFacts(profile: widget.profile),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Availability',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _availabilityPanel(context),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Consultation options',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DoctorConsultationOption(
                        title: 'Chat Consult',
                        price: widget.profile.chatPrice,
                        icon: Icons.chat_rounded,
                        description: 'Consultation fee',
                        onTap: () => _bookAppointment(ConsultationType.chat),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DoctorConsultationOption(
                        title: 'Video Consult',
                        price: widget.profile.videoPrice,
                        icon: Icons.videocam_rounded,
                        description: 'Consultation fee',
                        onTap: () => _bookAppointment(ConsultationType.video),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _bookAppointment(ConsultationType.video),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(64, 56),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.card,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                            child: Text(
                              'Book an appointment',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          const Icon(Icons.arrow_forward_rounded),
                        ],
                      ),
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
