//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:dio/dio.dart';
import 'package:built_value/serializer.dart';
import 'package:flutter_client/src/serializers.dart';
import 'package:flutter_client/src/auth/api_key_auth.dart';
import 'package:flutter_client/src/auth/basic_auth.dart';
import 'package:flutter_client/src/auth/bearer_auth.dart';
import 'package:flutter_client/src/auth/oauth.dart';
import 'package:flutter_client/src/api/analytics_api.dart';
import 'package:flutter_client/src/api/default_api.dart';
import 'package:flutter_client/src/api/details_api.dart';
import 'package:flutter_client/src/api/interview_api.dart';
import 'package:flutter_client/src/api/round_wise_report_api.dart';
import 'package:flutter_client/src/api/upload_files_api.dart';

class Openapi {
  static const String basePath = r'http://13.126.11.187:8000';

  final Dio dio;
  final Serializers serializers;

  Openapi({
    Dio? dio,
    Serializers? serializers,
    String? basePathOverride,
    List<Interceptor>? interceptors,
  })  : this.serializers = serializers ?? standardSerializers,
        this.dio = dio ??
            Dio(BaseOptions(
              baseUrl: basePathOverride ?? basePath,
              connectTimeout: const Duration(milliseconds: 5000),
              receiveTimeout: const Duration(milliseconds: 3000),
            )) {
    if (interceptors == null) {
      this.dio.interceptors.addAll([
        OAuthInterceptor(),
        BasicAuthInterceptor(),
        BearerAuthInterceptor(),
        ApiKeyAuthInterceptor(),
      ]);
    } else {
      this.dio.interceptors.addAll(interceptors);
    }
  }

  void setOAuthToken(String name, String token) {
    if (this.dio.interceptors.any((i) => i is OAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is OAuthInterceptor) as OAuthInterceptor).tokens[name] = token;
    }
  }

  void setBearerAuth(String name, String token) {
    if (this.dio.interceptors.any((i) => i is BearerAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BearerAuthInterceptor) as BearerAuthInterceptor).tokens[name] = token;
    }
  }

  void setBasicAuth(String name, String username, String password) {
    if (this.dio.interceptors.any((i) => i is BasicAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BasicAuthInterceptor) as BasicAuthInterceptor).authInfo[name] = BasicAuthInfo(username, password);
    }
  }

  void setApiKey(String name, String apiKey) {
    if (this.dio.interceptors.any((i) => i is ApiKeyAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((element) => element is ApiKeyAuthInterceptor) as ApiKeyAuthInterceptor).apiKeys[name] = apiKey;
    }
  }

  /// Get AnalyticsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AnalyticsApi getAnalyticsApi() {
    return AnalyticsApi(dio, serializers);
  }

  /// Get DefaultApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  DefaultApi getDefaultApi() {
    return DefaultApi(dio, serializers);
  }

  /// Get DetailsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  DetailsApi getDetailsApi() {
    return DetailsApi(dio, serializers);
  }

  /// Get InterviewApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  InterviewApi getInterviewApi() {
    return InterviewApi(dio, serializers);
  }

  /// Get RoundWiseReportApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  RoundWiseReportApi getRoundWiseReportApi() {
    return RoundWiseReportApi(dio, serializers);
  }

  /// Get UploadFilesApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  UploadFilesApi getUploadFilesApi() {
    return UploadFilesApi(dio, serializers);
  }
}
