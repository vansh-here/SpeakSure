import 'dart:io';
import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../constants/app_constants.dart';

class UploadService {
  final ApiClient _api;

  UploadService(this._api);

  /// Upload resume (multipart file)
  Future<Map<String, dynamic>?> uploadResume(File file) async {
    final fileName = file.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final response = await _api.handleApiCall(
          () => _api.post(AppConstants.uploadResume, data: formData),
    );

    if (response is Map<String, dynamic>) {
      return response;
    }
    return null;
  }
}
