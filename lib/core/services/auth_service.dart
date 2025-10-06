import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../constants/app_constants.dart';
import '../../data/models/api_models.dart';

class AuthService {
  final ApiClient _api;
  final SharedPreferences _prefs;

  AuthService(this._api, this._prefs);

  /// Create a user (POST /user?name=xxx)
  Future<CreateUserResponse> createUser({
    required String name,
    String? email,
    int? age,
    String? goal,
    String? resumePath,
  }) async {
    // Backend only accepts name as query parameter
    final response = await _api.handleApiCall(
      () => _api.post('${AppConstants.createUser}?name=${Uri.encodeComponent(name)}'),
    );
    
    final userResponse = CreateUserResponse.fromJson(response as Map<String, dynamic>);
    
    // Store user ID locally
    await _prefs.setString('user_id', userResponse.userId);
    await _prefs.setString('user_name', userResponse.name);
    
    return userResponse;
  }

  /// Upload resume (POST /upload_resume)
  Future<UploadResumeResponse> uploadResume({
    String? filePath,
    Uint8List? fileBytes,
    required String fileName,
    required String fileType,
  }) async {
    MultipartFile fileMultipart;

    if (fileBytes != null) {
      fileMultipart = MultipartFile.fromBytes(fileBytes, filename: fileName);
    } else if (filePath != null) {
      final file = File(filePath);
      fileMultipart = await MultipartFile.fromFile(file.path, filename: fileName);
    } else {
      throw ArgumentError('Either filePath or fileBytes must be provided for resume upload');
    }

    final formData = FormData.fromMap({
      'file': fileMultipart,
      'file_type': fileType,
    });

    final response = await _api.handleApiCall(
      () => _api.post(AppConstants.uploadResume, data: formData),
    );
    
    return UploadResumeResponse.fromJson(response as Map<String, dynamic>);
  }

  /// Get user analytics (GET /Analytics/)
  Future<UserAnalyticsResponse> getUserAnalytics() async {
    final response = await _api.handleApiCall(
      () => _api.get(AppConstants.getAnalytics),
    );
    
    return UserAnalyticsResponse.fromJson(response as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _prefs.remove('user_id');
    await _prefs.remove('user_name');
    await _api.clearAuth();
  }

  bool get isAuthenticated {
    final userId = _prefs.getString('user_id');
    return userId != null && userId.isNotEmpty;
  }

  String? get userId => _prefs.getString('user_id');
  String? get userName => _prefs.getString('user_name');
}
