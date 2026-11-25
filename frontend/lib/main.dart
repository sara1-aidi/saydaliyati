import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app_theme.dart';
import 'screens/auth_gate.dart';

void main() {
  runApp(const ProviderScope(child: SaydaliyatiApp()));
}

class SaydaliyatiApp extends StatelessWidget {
  const SaydaliyatiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saydaliyati',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      home: const AuthGate(), // Login -> pharmacist dashboard OR client store
    );
  }
}
