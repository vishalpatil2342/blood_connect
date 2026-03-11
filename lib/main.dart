import 'package:blood_connect/features/auth/presentation/screens/splash_screen.dart';
import 'package:blood_connect/features/auth/presentation/screens/register_screen.dart';
import 'package:blood_connect/features/patient/presentation/screens/home_screen.dart';
import 'package:blood_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(const ProviderScope(child: BloodConnectApp()));
}

class BloodConnectApp extends ConsumerWidget {
  const BloodConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the auth state directly
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Blood Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFE60000),
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE60000),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      // 2. Declaratively set the home route
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const HomeScreen();
          } else {
            return const RegisterScreen();
          }
        },
        loading: () => const SplashScreen(), // Shows while Firebase checks status
        error: (error, stack) => const RegisterScreen(), // Fallback
      ),
    );
  }
}