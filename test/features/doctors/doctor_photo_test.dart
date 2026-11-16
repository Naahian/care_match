import 'package:care_match/features/home/domain/entities/featured_doctor.dart';
import 'package:care_match/features/home/presentation/controllers/home_state.dart';
import 'package:care_match/features/home/presentation/widgets/featured_doctors_section.dart';
import 'package:care_match/features/doctors/domain/entities/doctor.dart';
import 'package:care_match/features/doctors/presentation/controllers/doctors_state.dart';
import 'package:care_match/features/doctors/presentation/widgets/doctors_results.dart';
import 'package:care_match/features/doctors/data/models/doctor_model.dart';
import 'package:care_match/shared/widgets/doctor_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home and directory cards receive the API photo URL', (
    tester,
  ) async {
    const url = 'https://example.com/doctor.jpg?v=2';
    final sections = <Widget>[
      FeaturedDoctorsSection(
        state: const HomeState(
          hasLoaded: true,
          doctors: [
            FeaturedDoctor(id: 'doctor', name: 'Doctor', photoUrl: url),
          ],
        ),
        onRetry: () {},
      ),
      DoctorsResults(
        state: DoctorsState(
          hasLoaded: true,
          doctors: [Doctor(id: 'doctor', name: 'Doctor', photoUrl: url)],
        ),
        onRetry: () {},
      ),
    ];
    for (final section in sections) {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: section)));
      final avatar = tester.widget<DoctorAvatar>(find.byType(DoctorAvatar));
      expect(avatar.photoUrl, url);
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<NetworkImage>());
      expect((image.image as NetworkImage).url, url);
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'missing and blank photos show a person icon even for sample names',
    (tester) async {
      for (final url in [null, '', '   ']) {
        await tester.pumpWidget(
          MaterialApp(
            home: DoctorAvatar(doctorName: 'Dr. Emily Carter', photoUrl: url),
          ),
        );
        expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
        expect(find.byType(Image), findsNothing);
      }
    },
  );

  test('missing or invalid doctor photo does not break directory decoding', () {
    for (final value in [null, '', 'invalid', 'file:///private/photo', 42]) {
      expect(
        DoctorModel.fromJson({'uid': 'doctor', 'photo_url': value}).photoUrl,
        isNull,
      );
    }
  });

  testWidgets(
    'remote photo takes precedence over demo portraits and has an error fallback',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DoctorAvatar(
            doctorName: 'Dr. Emily Carter',
            photoUrl: 'https://example.com/doctor.jpg',
          ),
        ),
      );
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<NetworkImage>());
      expect(
        (image.image as NetworkImage).url,
        'https://example.com/doctor.jpg',
      );
      expect(image.fit, BoxFit.cover);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
