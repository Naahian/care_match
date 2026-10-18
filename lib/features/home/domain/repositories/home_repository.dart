import '../entities/featured_doctor.dart';

abstract interface class HomeRepository {
  Future<List<FeaturedDoctor>> getFeaturedDoctors();
}

class HomeException implements Exception {
  const HomeException(this.message, {this.cause});

  final String message;
  final Object? cause;
}
