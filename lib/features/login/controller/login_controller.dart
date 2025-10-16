import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/auth_service.dart';
import '../../../features/profile/model/user_model.dart';

// Login state
class LoginState {
  final bool isLoading;
  final UserModel? user;
  final String? error;
  final bool isSuccess;

  const LoginState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isSuccess = false,
  });

  LoginState copyWith({
    bool? isLoading,
    UserModel? user,
    String? error,
    bool? isSuccess,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// Login controller
class LoginController extends StateNotifier<LoginState> {
  final AuthService _authService;

  LoginController(this._authService) : super(const LoginState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('Login controller: attempting login with $email');
      final result = await _authService.login(email, password);
      
      print('Login controller: result isSuccess = ${result.isSuccess}');
      
      if (result.isSuccess && result.user != null) {
        print('Login controller: login successful, setting state');
        state = state.copyWith(
          isLoading: false,
          user: result.user,
          isSuccess: true,
        );
      } else {
        print('Login controller: login failed - ${result.error}');
        state = state.copyWith(
          isLoading: false,
          error: result.error ?? 'Login failed',
        );
      }
    } catch (e) {
      print('Login controller: exception caught - $e');
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred: $e',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearState() {
    state = const LoginState();
  }
}

// Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final loginControllerProvider = StateNotifierProvider<LoginController, LoginState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return LoginController(authService);
});