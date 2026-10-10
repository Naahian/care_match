import 'package:care_match/features/doctors/presentation/widgets/doctor_profile.dart';
import 'package:care_match/core/constants/constants.dart';
import 'package:care_match/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/appointment_draft.dart';
import '../widgets/appointment_continue_button.dart';
import '../widgets/appointment_doctor_card.dart';
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

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Book Appointment'), centerTitle: true),
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
                    AppointmentDoctorCard(
                      draft: _draft,
                      showProfileDetails: true,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Consultation type',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns =
                            constraints.maxWidth < 340 ||
                                MediaQuery.textScalerOf(context).scale(14) > 20
                            ? 1
                            : 2;
                        return Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: ConsultationType.values
                              .map(
                                (type) => SizedBox(
                                  width:
                                      (constraints.maxWidth -
                                          AppSpacing.sm * (columns - 1)) /
                                      columns,
                                  child: ConsultationTypeCard(
                                    type: type,
                                    price: _draft.priceFor(type),
                                    selected: _draft.type == type,
                                    onTap: () => setState(() {
                                      _draft.type = type;
                                    }),
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Reason for visit',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _reasonController,
                      minLines: 3,
                      maxLines: 5,
                      maxLength: 500,
                      onChanged: (value) => _draft.reason = value,
                      decoration: const InputDecoration(
                        hintText: 'Describe the reason for your visit',
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
                      minLines: 3,
                      maxLines: 5,
                      onChanged: (value) => _draft.notes = value,
                      decoration: const InputDecoration(
                        hintText:
                            'Add additional details, symptoms, or questions for the doctor…',
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
                    pathParameters: {
                      'doctorId': doctorProfileId(_draft.doctor.summary.name),
                    },
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
