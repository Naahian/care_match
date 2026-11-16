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
        icon: Icons.school_outlined,
        title: 'Qualifications',
        value: profile.qualifications.isEmpty
            ? 'Not provided'
            : profile.qualifications.join(', '),
      ),
      DoctorProfileFactCard(
        icon: Icons.local_hospital_outlined,
        title: 'Hospital & location',
        value: profile.practiceLocation ?? profile.hospital,
      ),
      DoctorProfileFactCard(
        icon: Icons.schedule_outlined,
        title: 'Consultation hours',
        value: profile.timeAvailable.isEmpty
            ? 'Not provided'
            : profile.timeAvailable
                  .map((range) => '${range.start} – ${range.end}')
                  .join(', '),
      ),
    ];
    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.sm),
              cards[i],
            ],
          ],
        ),
      ),
    );
  }
}
