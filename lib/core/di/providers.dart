import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';
import '../services/auth_service.dart';
import '../services/interview_service.dart';
import '../services/report_service.dart';
import '../services/question_service.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/interview_repository_impl.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/interview_repository.dart';
import '../../domain/repositories/report_repository.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnv();
});

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final apiClientProvider = FutureProvider<ApiClient>((ref) async {
  final config = ref.watch(appConfigProvider);
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return ApiClient.create(config, prefs);
});

// Service Providers
final authServiceProvider = FutureProvider<AuthService>((ref) async {
  final apiClient = await ref.watch(apiClientProvider.future);
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return AuthService(apiClient, prefs);
});

final interviewServiceProvider = FutureProvider<InterviewService>((ref) async {
  final apiClient = await ref.watch(apiClientProvider.future);
  return InterviewService(apiClient);
});

final reportServiceProvider = FutureProvider<ReportService>((ref) async {
  final apiClient = await ref.watch(apiClientProvider.future);
  return ReportService(apiClient);
});

final questionServiceProvider = FutureProvider<QuestionService>((ref) async {
  final apiClient = await ref.watch(apiClientProvider.future);
  return QuestionService(apiClient);
});

// Repository Providers
final userRepositoryProvider = FutureProvider<UserRepository>((ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return UserRepositoryImpl(apiClient: api);
});

final interviewRepositoryProvider = FutureProvider<InterviewRepository>((ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return InterviewRepositoryImpl(apiClient: api);
});

final reportRepositoryProvider = FutureProvider<ReportRepository>((ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return ReportRepositoryImpl(apiClient: api);
});





