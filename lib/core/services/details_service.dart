import '../network/api_client.dart';
import '../constants/app_constants.dart';

class DetailsService {
  final ApiClient _api;

  DetailsService(this._api);

  Future<Map<String, dynamic>?> getInterviewStatus(String conversationId) async {
    final response = await _api.handleApiCall(
          () => _api.get(AppConstants.getInterviewStatus, query: {
        'conversation_id': conversationId,
      }),
    );
    if (response is Map<String, dynamic>) {
      return response;
    }
    return null;
  }
}
