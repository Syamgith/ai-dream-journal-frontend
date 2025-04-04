import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/google_sign_in_button.dart';
import 'register_page.dart';
import '../../../../core/widgets/error_message_display.dart';
import '../../../../core/utils/error_formatter.dart';
import '../../../../core/widgets/keyboard_dismissible.dart';
import '../../../../core/utils/keyboard_utils.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _isLoggingIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null;
        _isLoggingIn = true;
      });

      try {
        await ref.read(authProvider.notifier).login(
              _emailController.text.trim(),
              _passwordController.text,
            );

        // After successful login, navigate to the home page
        if (mounted && context.mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = ErrorFormatter.format(e);
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoggingIn = false;
          });
        }
      }
    }
  }

  Future<void> _loginAsGuest() async {
    setState(() {
      _errorMessage = null;
      _isLoggingIn = true;
    });

    try {
      await ref.read(authProvider.notifier).loginAsGuest();

      // After successful guest login, navigate to the home page
      if (mounted && context.mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = ErrorFormatter.format(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _errorMessage = null;
      _isLoggingIn = true;
    });

    try {
      await ref.read(authProvider.notifier).loginWithGoogle();

      // After successful Google login, navigate to the home page
      if (mounted && context.mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = ErrorFormatter.format(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AsyncLoading || _isLoggingIn;

    return KeyboardDismissible(
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // App Logo or Icon
                    const Icon(
                      Icons.cloud_outlined,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),

                    // App Title
                    const Text(
                      'Dreami Diary',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // App Subtitle
                    const Text(
                      'Record and explore your dreams',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Login Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          AuthTextField(
                            label: 'Email',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          AuthTextField(
                            label: 'Password',
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white70,
                              ),
                              onPressed: _togglePasswordVisibility,
                            ),
                          ),

                          if (_errorMessage != null)
                            ErrorMessageDisplay(
                              message: _errorMessage!,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                            ),

                          const SizedBox(height: 24),

                          // Login Button
                          Container(
                            margin: const EdgeInsets.only(top: 30.0),
                            child: AuthButton(
                              text: 'Login',
                              isLoading: _isLoggingIn,
                              onPressed: () => KeyboardUtils.hideKeyboardThen(
                                  context, _login),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Google Sign-In Button
                          GoogleSignInButton(
                            onPressed: _loginWithGoogle,
                            isLoading: isLoading,
                          ),

                          const SizedBox(height: 4),

                          // Google sign-in description
                          const Text(
                            'Sign in with your Google account',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 16),

                          // Guest Login Button
                          AuthButton(
                            text: 'Continue as Guest',
                            onPressed: _loginAsGuest,
                            isLoading: isLoading,
                            backgroundColor: Colors.transparent,
                            textColor: Colors.white,
                            borderColor: Colors.white70,
                          ),

                          const SizedBox(height: 8),

                          // Guest login description
                          const Text(
                            'No account needed. Try the app without registration.',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 24),

                          // Register Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(color: Colors.white70),
                              ),
                              GestureDetector(
                                onTap: _navigateToRegister,
                                child: const Text(
                                  'Register',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
