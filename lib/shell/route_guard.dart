import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../core/auth/sign_in_screen.dart';

/// Simple route guard for authenticated-only screens
class RouteGuard extends StatelessWidget {
  final Widget child;

  const RouteGuard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    if (user == null) {
      return const SignInScreen();
    }

    return child;
  }
}