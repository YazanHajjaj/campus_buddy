import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final AuthService _authService = AuthService();

  bool _loading = false;
  String? _error;

  /// Runs an async action with loading + error handling.
  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await action();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign In")),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.school, size: 60),
              const SizedBox(height: 20),
              Text(
                "Campus Buddy Authentication",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 40),

              // Anonymous Sign-in
              FilledButton(
                onPressed: _loading
                    ? null
                    : () => _run(() async {
                  await _authService.signInAnonymously();
                }),
                child: const Text("Sign In Anonymously"),
              ),

              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 30),

              // Email/Password Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _email,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                      (v == null || v.isEmpty) ? "Enter email" : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                      (v == null || v.length < 6)
                          ? "Min 6 characters"
                          : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Email Sign-in
                  FilledButton(
                    onPressed: _loading
                        ? null
                        : () {
                      if (!_formKey.currentState!.validate()) return;
                      _run(() async {
                        await _authService.signInWithEmailAndPassword(
                          email: _email.text.trim(),
                          password: _password.text.trim(),
                        );
                      });
                    },
                    child: const Text("Sign In"),
                  ),

                  const SizedBox(width: 20),

                  // Email Registration
                  OutlinedButton(
                    onPressed: _loading
                        ? null
                        : () {
                      if (!_formKey.currentState!.validate()) return;
                      _run(() async {
                        await _authService.registerWithEmailAndPassword(
                          email: _email.text.trim(),
                          password: _password.text.trim(),
                        );
                      });
                    },
                    child: const Text("Register"),
                  ),
                ],
              ),

              const SizedBox(height: 100),
            ],
          ),

          if (_loading)
            const LinearProgressIndicator(minHeight: 5),
        ],
      ),
    );
  }
}
