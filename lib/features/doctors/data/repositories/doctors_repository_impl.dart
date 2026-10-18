import 'package:dio/dio.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/repositories/doctors_repository.dart';
import '../models/doctor_model.dart';

class DoctorsRepositoryImpl implements DoctorsRepository {
  DoctorsRepositoryImpl({required this.dio});
  final Dio dio;

  @override
  Future<List<Doctor>> getDoctors() async {
    try {
      final response = await dio.get<Object?>(ApiEndpoints.doctors);
      final data = ApiResponse.fromJson(response.data).data;
      if (data is! List) {
        throw const FormatException('Expected a list of doctors.');
      }
      return List.unmodifiable(
        data.map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('Expected a doctor object.');
          }
          return DoctorModel.fromJson(item);
        }),
      );
    } on DioException catch (error) {
      throw DoctorsException(
        'Could not load doctors. Please try again.',
        cause: error,
        statusCode: error.response?.statusCode,
      );
    } on ApiResponseException catch (error) {
      throw DoctorsException(
        'Could not load doctors. Please try again.',
        cause: error,
        statusCode: error.statusCode,
      );
    } on FormatException catch (error) {
      throw DoctorsException('The doctors response was invalid.', cause: error);
    }
  }
}
