import 'dart:async';
import 'dart:io';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/api_models.dart';
import '../../domain/repositories/user_repository.dart';
import 'package:dio/dio.dart';

class UserRepositoryImpl implements UserRepository {
  final ApiClient apiClient;

  UserRepositoryImpl({required this.apiClient});

  @override
  Future<UserModel?> getCurrentUser() async {
    // This endpoint doesn't exist in FastAPI backend
    throw UnimplementedError('getCurrentUser is not supported by the backend');
  }

  @override
  Future<UserModel> saveUser(UserModel user) async {
    // This endpoint doesn't exist in FastAPI backend
    throw UnimplementedError('saveUser is not supported by the backend');
  }

  // FastAPI-compatible methods
  Future<CreateUserResponse> createUser(String name) async {
    final response = await apiClient.handleApiCall(
      () => apiClient.post('${AppConstants.createUser}?name=${Uri.encodeComponent(name)}'),
    );
    return CreateUserResponse.fromJson(response as Map<String, dynamic>);
  }

  Future<UploadResumeResponse> uploadResume(File file, String fileName) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final response = await apiClient.handleApiCall(
      () => apiClient.post(AppConstants.uploadResume, data: formData),
    );
    return UploadResumeResponse.fromJson(response as Map<String, dynamic>);
  }
}





