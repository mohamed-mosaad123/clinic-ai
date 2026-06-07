import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/auth_service.dart';
import '../../../models/user_model.dart';

final authServiceProvider = Provider((ref) => AuthService());

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState.initial());

  Future<void> login({required String email, required String password, required String role}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _authService.login(email: email, password: password, role: role);
    if (result.isSuccess) {
      state = state.copyWith(isLoading: false, user: result.user);
    } else {
      state = state.copyWith(isLoading: false, errorMessage: result.errorMessage);
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _authService.register(
      userName: data['userName'],
      email: data['email'],
      password: data['password'],
      role: data['role'],
      phoneNumber: data['phoneNumber'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      dateOfBirth: data['dateOfBirth'],
      gender: data['gender'],
      address: data['address'],
    );
    if (result.isSuccess) {
      state = state.copyWith(isLoading: false, user: result.user);
    } else {
      state = state.copyWith(isLoading: false, errorMessage: result.errorMessage);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = AuthState.initial();
  }

  void restoreSession(UserModel? user) {
    if (user != null) {
      state = state.copyWith(user: user);
    }
  }
}

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;

  AuthState({this.user, this.isLoading = false, this.errorMessage});

  factory AuthState.initial() => AuthState();

  AuthState copyWith({UserModel? user, bool? isLoading, String? errorMessage}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isAuthenticated => user != null;
}
