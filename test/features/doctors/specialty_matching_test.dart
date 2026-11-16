import 'package:care_match/features/doctors/domain/utils/specialty_matching.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ignores general and internal qualifiers on either label', () {
    expect(
      matchesRecommendedSpecialty('Internal Medicine', 'Medicine'),
      isTrue,
    );
    expect(matchesRecommendedSpecialty('General Surgery', 'Surgery'), isTrue);
    expect(
      matchesRecommendedSpecialty('Medicine', 'General Internal Medicine'),
      isTrue,
    );
    expect(
      matchesRecommendedSpecialty(' INTERNAL   medecine ', 'Medecine'),
      isTrue,
    );
  });
  test('matches whole words without losing specific specialty terms', () {
    expect(
      matchesRecommendedSpecialty('General Medicine', 'Medicine and Surgery'),
      isTrue,
    );
    expect(
      matchesRecommendedSpecialty('Internal Medicine', 'Surgery'),
      isFalse,
    );
    expect(
      matchesRecommendedSpecialty('General Surgery', 'Neurosurgery'),
      isFalse,
    );
    expect(
      matchesRecommendedSpecialty('General Pediatric Surgery', 'Surgery'),
      isFalse,
    );
    expect(matchesRecommendedSpecialty('General', 'Cardiology'), isFalse);
  });
}
