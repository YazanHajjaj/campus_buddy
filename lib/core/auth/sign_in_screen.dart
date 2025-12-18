import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// PHASE 1 — AUTHENTICATION
/// Sign-in screen for anonymous and email/password auth.
/// This screen handles UI + validation only.
/// Navigation is controlled by AuthGate.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final AuthService _authService = AuthService();

  bool _loading = false;
  String? _error;

  // ---------------------------------------------------------------------------
  // AUTH EXECUTION WRAPPER
  // ---------------------------------------------------------------------------

  /// Runs an auth action while managing loading + error state.
  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await action();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.school, size: 60),
              const SizedBox(height: 20),

              Text(
                'Campus Buddy Authentication',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 40),

              // ----------------------------------------------------------------
              // ANONYMOUS SIGN-IN (DEV + FALLBACK)
              // ----------------------------------------------------------------
              FilledButton(
                onPressed: _loading
                    ? null
                    : () => _run(
                      () => _authService.signInAnonymously(),
                ),
                child: const Text('Continue as Guest'),
              ),

              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 30),

              // ----------------------------------------------------------------
              // EMAIL / PASSWORD FORM
              // ----------------------------------------------------------------
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!value.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 6) {
                          return 'Minimum 6 characters';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ----------------------------------------------------------------
              // ERROR DISPLAY
              // ----------------------------------------------------------------
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 20),

              // ----------------------------------------------------------------
              // ACTION BUTTONS
              // ----------------------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton(
                    onPressed: _loading
                        ? null
                        : () {
                      if (!_formKey.currentState!.validate()) return;

                      _run(
                            () => _authService.signInWithEmailAndPassword(
                          email: _emailController.text.trim(),
                          password:
                          _passwordController.text.trim(),
                        ),
                      );
                    },
                    child: const Text('Sign In'),
                  ),

                  const SizedBox(width: 20),

                  OutlinedButton(
                    onPressed: _loading
                        ? null
                        : () {
                      if (!_formKey.currentState!.validate()) return;

                      _run(
                            () => _authService
                            .registerWithEmailAndPassword(
                          email: _emailController.text.trim(),
                          password:
                          _passwordController.text.trim(),
                        ),
                      );
                    },
                    child: const Text('Register'),
                  ),
                ],
              ),

              const SizedBox(height: 100),
            ],
          ),

          // --------------------------------------------------------------------
          // LOADING INDICATOR
          // --------------------------------------------------------------------
          if (_loading)
            const LinearProgressIndicator(minHeight: 4),
        ],
      ),
    );
  }
}
