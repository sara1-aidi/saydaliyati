import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';
import 'client/client_shell.dart';
import 'pharmacist/pharmacist_dashboard_screen.dart';

/// Decides which screen to show from the authenticated user (Riverpod).
///   nobody signed in -> Login   |   pharmacist -> dashboard   |   client -> store
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    if (user == null) return const LoginScreen();
    return user.isPharmacist
        ? const PharmacistDashboardScreen()
        : const ClientShell();
  }
}
