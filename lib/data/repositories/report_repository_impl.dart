import 'dart:async';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../models/report_model.dart';
import '../models/api_models.dart';
import '../../domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ApiClient apiClient;

  ReportRepositoryImpl({required this.apiClient});

  @override
  Future<ReportModel> generateReport({required String interviewId}) async {
    // This endpoint doesn't exist in FastAPI backend
    throw UnimplementedError('generateReport is not supported by the backend');
  }

  @override
  Future<List<ReportModel>> listReports({required String userId}) async {
    // This endpoint doesn't exist in FastAPI backend
    throw UnimplementedError('listReports is not supported by the backend');
  }

  // FastAPI-compatible methods
  Future<RoundWiseReportResponse> getRoundWiseReport(int roundNumber) async {
    final path = AppConstants.getRoundWiseReport.replaceAll('{round_number}', roundNumber.toString());
    final response = await apiClient.handleApiCall(
      () => apiClient.get(path),
    );
    return RoundWiseReportResponse.fromJson(response as Map<String, dynamic>);
  }

  Future<UserAnalyticsResponse> getUserAnalytics() async {
    final response = await apiClient.handleApiCall(
      () => apiClient.get(AppConstants.getAnalytics),
    );
    return UserAnalyticsResponse.fromJson(response as Map<String, dynamic>);
  }
}





