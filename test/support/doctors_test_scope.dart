import 'package:care_match/features/doctors/domain/entities/doctor.dart';
import 'package:care_match/features/doctors/domain/repositories/doctors_repository.dart';
import 'package:care_match/features/doctors/providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Keeps app navigation tests independent of Firebase and the live backend.
Widget doctorsTestScope(Widget child) => ProviderScope(
  overrides: [
    doctorsRepositoryProvider.overrideWithValue(TestDoctorsRepository()),
  ],
  child: child,
);

class TestDoctorsRepository implements DoctorsRepository {
  @override
  Future<List<Doctor>> getDoctors() async => [
    Doctor(
      id: 'dr-emily-carter',
      name: 'Dr. Emily Carter',
      specialties: ['Internal Medicine'],
    ),
    Doctor(
      id: 'backend-farzana',
      name: 'Dr. Farzana Rahman',
      specialties: ['General Physician'],
    ),
    Doctor(
      id: 'backend-imtiaz',
      name: 'Dr. Imtiaz Hossain',
      specialties: ['Dermatology'],
    ),
  ];
}
