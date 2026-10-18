import '../../domain/entities/featured_doctor.dart';

class HomeState {
  const HomeState({
    this.doctors = const [],
    this.isLoading = false,
    this.hasLoaded = false,
    this.errorMessage,
  });

  final List<FeaturedDoctor> doctors;
  final bool isLoading;
  final bool hasLoaded;
  final String? errorMessage;
}
