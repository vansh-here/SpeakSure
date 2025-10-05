import '../network/api_client.dart';
import '../constants/app_constants.dart';

class AnalyticsService {
  final ApiClient _api;

  AnalyticsService(this._api);

  Future<Map<String, dynamic>?> getUserAnalytics() async {
    final response = await _api.handleApiCall(
          () => _api.get(AppConstants.getAnalytics),
    );
    if (response is Map<String, dynamic>) {
      return response;
    }
    return null;
  }
}
