import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/home_repository.dart';
import '../../providers.dart';
import 'home_state.dart';

final homeControllerProvider = NotifierProvider<HomeController, HomeState>(
  HomeController.new,
);

class HomeController extends Notifier<HomeState> {
  @override
  HomeState build() => const HomeState();

  Future<void> loadDoctors({bool refresh = false}) async {
    if (state.isLoading || (state.hasLoaded && !refresh)) return;
    state = HomeState(
      doctors: state.doctors,
      hasLoaded: state.hasLoaded,
      isLoading: true,
    );
    try {
      final doctors = await ref
          .read(homeRepositoryProvider)
          .getFeaturedDoctors();
      if (!ref.mounted) return;
      state = HomeState(
        doctors: List.unmodifiable(doctors.take(5)),
        hasLoaded: true,
      );
    } catch (error) {
      if (!ref.mounted) return;
      state = HomeState(
        doctors: state.doctors,
        hasLoaded: state.hasLoaded,
        errorMessage: error is HomeException
            ? error.message
            : 'Could not load doctors. Please try again.',
      );
    }
  }
}
