import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../services/auth_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';

// Reset Password State
class ResetPasswordState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const ResetPasswordState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  ResetPasswordState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return ResetPasswordState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// Reset Password Controller
class ResetPasswordController extends StateNotifier<ResetPasswordState> {
  final AuthService _authService;

  ResetPasswordController(this._authService) : super(const ResetPasswordState());

  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.resetPassword(email);
      
      if (result.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.error ?? 'Failed to send reset email',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearState() {
    state = const ResetPasswordState();
  }
}

// Provider
final resetPasswordControllerProvider = StateNotifierProvider<ResetPasswordController, ResetPasswordState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return ResetPasswordController(authService);
});

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resetState = ref.watch(resetPasswordControllerProvider);
    
    // Listen to state changes
    ref.listen<ResetPasswordState>(resetPasswordControllerProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
          ),
        );
      } else if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.resetPasswordSuccess),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back to login after showing success message
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            context.go(AppConstants.loginRoute);
          }
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppConstants.loginRoute),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              const Icon(
                Icons.lock_reset,
                size: 100,
                color: Colors.blue,
              ),
              const SizedBox(height: 32),
              
              // Title and Description
              const Text(
                'Reset Your Password',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Email Field
              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
                hintText: 'Enter your email address',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(AppConstants.emailPattern).hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Reset Password Button
              CustomButton(
                text: 'Send Reset Link',
                isLoading: resetState.isLoading,
                onPressed: _handleResetPassword,
              ),
              const SizedBox(height: 16),
              
              // Back to Login Button
              TextButton(
                onPressed: () => context.go(AppConstants.loginRoute),
                child: const Text('Back to Login'),
              ),
              
              // Success Message
              if (resetState.isSuccess) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Password reset link sent! Check your email and follow the instructions to reset your password.',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleResetPassword() {
    if (_formKey.currentState!.validate()) {
      ref.read(resetPasswordControllerProvider.notifier).resetPassword(
        _emailController.text.trim(),
      );
    }
  }
}