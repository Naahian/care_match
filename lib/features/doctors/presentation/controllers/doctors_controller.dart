import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/doctors_repository.dart';
import '../../providers.dart';
import 'doctors_state.dart';

final doctorsControllerProvider =
    NotifierProvider<DoctorsController, DoctorsState>(DoctorsController.new);

class DoctorsController extends Notifier<DoctorsState> {
  @override
  DoctorsState build() => const DoctorsState();

  void search(String query) => state = state.copyWith(query: query.trim());
  void selectSpecialty(String specialty) =>
      state = state.copyWith(specialty: specialty);

  Future<void> load({bool refresh = false}) async {
    if (state.isLoading || (state.hasLoaded && !refresh)) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final doctors = await ref.read(doctorsRepositoryProvider).getDoctors();
      if (!ref.mounted) return;
      state = state.copyWith(
        doctors: List.unmodifiable(doctors),
        isLoading: false,
        hasLoaded: true,
      );
    } catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: error is DoctorsException
            ? error.message
            : 'Could not load doctors. Please try again.',
      );
    }
  }
}
