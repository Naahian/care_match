import 'package:dio/dio.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/symptom_intake.dart';
import '../../domain/entities/triage_assessment.dart';
import '../../domain/repositories/nursai_repository.dart';
import '../models/triage_request_model.dart';
import '../models/triage_assessment_model.dart';

class NursaiRepositoryImpl implements NursaiRepository {
  NursaiRepositoryImpl({required this.dio});
  final Dio dio;

  @override
  Future<TriageAssessment> assess(SymptomIntake intake) async {
    try {
      final response = await dio.post<Object?>(
        ApiEndpoints.triage,
        data: TriageRequestModel(intake).toJson(),
      );
      return TriageAssessmentModel.fromJson(
        ApiResponse.fromJson(response.data).data,
      );
    } on DioException catch (error) {
      throw NursaiException(
        error.response?.statusCode == 401
            ? 'Please sign in again to assess your symptoms.'
            : 'Could not assess your symptoms. Please try again.',
        cause: error,
      );
    } on ApiResponseException catch (error) {
      throw NursaiException(
        'Could not assess your symptoms. Please try again.',
        cause: error,
      );
    } on FormatException catch (error) {
      throw NursaiException(
        'The assessment response was invalid. Please try again.',
        cause: error,
      );
    }
  }
}
