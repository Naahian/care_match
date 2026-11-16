import 'package:care_match/core/constants/constants.dart';
import 'package:care_match/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/appointment_draft.dart';
import '../widgets/appointment_continue_button.dart';
import '../widgets/appointment_doctor_card.dart';
import '../widgets/booking_flow_header.dart';
import '../widgets/consultation_type_card.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key, required this.draft});
  final AppointmentDraft draft;
  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  late final _draft = widget.draft;
  late final _reasonController = TextEditingController(text: _draft.reason);
  late final _notesController = TextEditingController(text: _draft.notes);
  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(BuildContext context, String hint) {
    final scheme = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: AppRadius.card,
      borderSide: BorderSide(color: scheme.outlineVariant),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: Theme.of(context).textTheme.bodySmall,
      fillColor: scheme.surface,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              const BookingFlowHeader(title: 'Book appointment', step: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  children: [
                    AppointmentDoctorCard(
                      draft: _draft,
                      showProfileDetails: false,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Consultation type',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Column(
                      children: ConsultationType.values
                          .map(
                            (type) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: ConsultationTypeCard(
                                type: type,
                                price: _draft.priceFor(type),
                                selected: _draft.type == type,
                                onTap: () => setState(() => _draft.type = type),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Reason for visit',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _reasonController,
                      minLines: 2,
                      maxLines: 4,
                      maxLength: 500,
                      onChanged: (value) => _draft.reason = value,
                      decoration: _fieldDecoration(
                        context,
                        'Describe the reason for your visit',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Patient notes (optional)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _notesController,
                      minLines: 1,
                      maxLines: 4,
                      onChanged: (value) => _draft.notes = value,
                      decoration: _fieldDecoration(
                        context,
                        'Add any notes for the doctor',
                      ),
                    ),
                  ],
                ),
              ),
              AppointmentContinueButton(
                label: 'Continue',
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  context.pushNamed(
                    AppRoutes.appointmentDateTime,
                    pathParameters: {'doctorId': _draft.doctor.routeId},
                    extra: _draft,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
