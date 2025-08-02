import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

class AuthUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profilePicture;

  AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profilePicture,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profilePicture: json['profile_picture'],
    );
  }
}

class AuthState {
  final AuthUser? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    AuthUser? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authRepository.login(
        email: email,
        password: password,
      );

      final userData = response['data']['medical_worker'];
      final user = AuthUser.fromJson(userData);

      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authRepository.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        phone: phone,
      );

      // Don't auto-login after registration
      state = state.copyWith(
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadUserProfile() async {
    try {
      final response = await _authRepository.getUserProfile();
      final user = AuthUser.fromJson(response['data']['medical_worker']);

      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        user: null,
        isAuthenticated: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authRepository.logout();
      state = const AuthState();
    } catch (e) {
      // Even if logout fails, clear local state
      state = const AuthState();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authRepository.updateProfile(data);
      final user = AuthUser.fromJson(response['data']['medical_worker']);

      state = state.copyWith(
        user: user,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> checkAuthStatus() async {
    try {
      final token = await _authRepository.getToken();
      if (token != null) {
        await loadUserProfile();
        return state.isAuthenticated;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
