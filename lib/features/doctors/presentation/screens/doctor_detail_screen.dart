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
  const DoctorDetailScreen({
    super.key,
    this.profile = sampleDoctorProfile,
    this.portrait,
  });
  final DoctorProfile profile;
  final Widget? portrait;

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
            color: scheme.primary,
            onPressed: () {
              setState(() => _isFavorite = !_isFavorite);
              // TODO: persist the favorite doctor selection.
            },
            icon: Icon(
              _isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'More options',
            iconColor: scheme.primary,
            onSelected: (value) {
              // TODO: handle sharing or reporting this doctor profile.
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'share', child: Text('Share profile')),
              PopupMenuItem(value: 'report', child: Text('Report profile')),
            ],
          ),
        ],
      ),
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
                      DoctorProfileHeader(
                        profile: widget.profile,
                        portrait: widget.portrait,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DoctorProfileFacts(profile: widget.profile),
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
                        description:
                            'Chat with ${widget.profile.summary.name} via secure messaging. Get a response within a few hours.',
                        onTap: () {
                          context.pushNamed(AppRoutes.chat);
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DoctorConsultationOption(
                        title: 'Video Consult',
                        price: widget.profile.videoPrice,
                        icon: Icons.videocam_rounded,
                        description:
                            'Have a face-to-face video consultation with ${widget.profile.summary.name}.',
                        onTap: () {
                          context.pushNamed(AppRoutes.video);
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: AppSpacing.page,
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        context.pushNamed(
                          AppRoutes.bookAppointment,
                          pathParameters: {
                            'doctorId': doctorProfileId(
                              widget.profile.summary.name,
                            ),
                          },
                          extra: AppointmentDraft(doctor: widget.profile),
                        );
                      },
                      style: FilledButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.card,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
