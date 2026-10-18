import 'package:dio/dio.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/featured_doctor.dart';
import '../../domain/repositories/home_repository.dart';
import '../models/featured_doctor_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({required this.dio});

  final Dio dio;

  @override
  Future<List<FeaturedDoctor>> getFeaturedDoctors() async {
    try {
      final response = await dio.get<Object?>(
        ApiEndpoints.doctors,
        queryParameters: {'limit': 5, 'verified': true},
      );
      final items = ApiResponse.fromJson(response.data).data;
      if (items is! List) {
        throw const FormatException('Expected a list of doctors.');
      }
      final doctors = <FeaturedDoctor>[];
      for (final item in items.take(5)) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Expected a doctor object.');
        }
        doctors.add(FeaturedDoctorModel.fromJson(item));
      }
      return List.unmodifiable(doctors);
    } on DioException catch (error) {
      throw HomeException(
        'Could not load doctors. Please try again.',
        cause: error,
      );
    } on ApiResponseException catch (error) {
      throw HomeException(
        'Could not load doctors. Please try again.',
        cause: error,
      );
    } on FormatException catch (error) {
      throw HomeException('The doctors response was invalid.', cause: error);
    }
  }
}
