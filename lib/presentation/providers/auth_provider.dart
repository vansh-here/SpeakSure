import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/api_models.dart';

// Authentication state
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? userId;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.userId,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? userId,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      error: error,
    );
  }
}

// Authentication notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      if (_authService.isAuthenticated) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          userId: _authService.userId,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createUser({
    required String name,
    required String email,
    required int age,
    required String goal,
    String? resumePath,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final createUserResponse = await _authService.createUser(
        name: name,
        email: email,
        age: age,
        goal: goal,
        resumePath: resumePath,
      );
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        userId: createUserResponse.userId,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> uploadResume({
    required String filePath,
    required String fileName,
    required String fileType,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.uploadResume(
        filePath: filePath,
        fileName: fileName,
        fileType: fileType,
      );
      state = state.copyWith(
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authService.logout();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<UserAnalyticsResponse> getUserAnalytics() async {
    return await _authService.getUserAnalytics();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider).value;
  if (authService == null) {
    throw Exception('AuthService not available');
  }
  return AuthNotifier(authService);
});
