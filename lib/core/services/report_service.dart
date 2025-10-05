import '../network/api_client.dart';
import '../constants/app_constants.dart';
import '../../data/models/api_models.dart';

class ReportService {
  final ApiClient _api;

  ReportService(this._api);

  /// Get round-wise report (GET /RoundWiseReport/{round_number})
  Future<RoundWiseReportResponse> getRoundWiseReport(int roundNumber) async {
    final path = AppConstants.getRoundWiseReport.replaceAll('{round_number}', roundNumber.toString());
    final response = await _api.handleApiCall(
      () => _api.get(path),
    );
    
    return RoundWiseReportResponse.fromJson(response as Map<String, dynamic>);
  }
}
