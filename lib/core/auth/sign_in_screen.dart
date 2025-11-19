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

  /// Executes an auth action and manages loading/error state.
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

              // Anonymous sign-in
              FilledButton(
                onPressed: _loading
                    ? null
                    : () => _run(() => _authService.signInAnonymously()),
                child: const Text("Sign In Anonymously"),
              ),

              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 30),

              // Email/Password form
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
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return "Enter email";
                        }
                        return null;
                      },
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
                      validator: (v) {
                        if (v == null || v.length < 6) {
                          return "Min 6 characters";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

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

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton(
                    onPressed: _loading
                        ? null
                        : () {
                      if (!_formKey.currentState!.validate()) return;
                      _run(() => _authService.signInWithEmailAndPassword(
                        email: _email.text.trim(),
                        password: _password.text.trim(),
                      ));
                    },
                    child: const Text("Sign In"),
                  ),

                  const SizedBox(width: 20),

                  OutlinedButton(
                    onPressed: _loading
                        ? null
                        : () {
                      if (!_formKey.currentState!.validate()) return;
                      _run(() => _authService.registerWithEmailAndPassword(
                        email: _email.text.trim(),
                        password: _password.text.trim(),
                      ));
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
