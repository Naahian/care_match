import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'doctor_profile.dart';
import 'doctor_profile_fact_card.dart';

class DoctorProfileFacts extends StatelessWidget {
  const DoctorProfileFacts({super.key, required this.profile});
  final DoctorProfile profile;

  @override
  Widget build(BuildContext context) {
    final cards = [
      DoctorProfileFactCard(
        icon: Icons.medical_services_outlined,
        title: 'Specialty',
        value: profile.summary.specialty,
      ),
      DoctorProfileFactCard(
        icon: Icons.local_hospital_outlined,
        title: 'Hospital',
        value: profile.hospital,
      ),
      DoctorProfileFactCard(
        icon: Icons.calendar_month_outlined,
        title: 'Availability',
        value: profile.summary.availability,
        isAvailable: profile.summary.availableToday,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 300 ||
            MediaQuery.textScalerOf(context).scale(14) > 20) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.sm),
                cards[i],
              ],
            ],
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.sm),
                Expanded(child: cards[i]),
              ],
            ],
          ),
        );
      },
    );
  }
}
