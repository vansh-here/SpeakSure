// This file is not used - we have our own auth implementation in lib/core/services/auth_service.dart
// Commenting out to avoid compilation errors

/*
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_client/src/api_util.dart';
import '../services/user_service.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final UserService _userService;

  AuthNotifier(this._userService) : super(const AuthState());

  Future<void> createUser({required String name}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _userService.createUser(name);
      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final dioProvider = Provider((ref) => Dio(BaseOptions(baseUrl: 'http://localhost:8000')));
final serializersProvider = Provider((ref) => standardSerializers);

final userServiceProvider = Provider(
      (ref) => UserService(ref.read(dioProvider), ref.read(serializersProvider)),
);

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
      (ref) => AuthNotifier(ref.read(userServiceProvider)),
);
*/
