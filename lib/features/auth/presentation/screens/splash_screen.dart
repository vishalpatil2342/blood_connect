import 'dart:async';
import 'package:blood_connect/features/patient/presentation/screens/home_screen.dart';
import 'package:blood_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_connect/features/auth/presentation/screens/register_screen.dart';

// ==========================================
// 1. WELCOME / SPLASH SCREEN
// ==========================================

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      final authState = ref.read(authStateProvider);
      
      authState.when(
        data: (user) {
          if (user != null) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
          }
        },
        loading: () {
          // If still loading after 2 seconds, wait for it to change via listener below
        },
        error: (_, __) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to changes in case it was loading during the timer check
    ref.listen(authStateProvider, (previous, next) {
      if (next.isLoading == false) {
        next.whenData((user) {
          if (user != null) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
          }
        });
      }
    });

    return Scaffold(
      body: SizedBox.expand(
        child: Image.asset(
          "assets/images/splash_logo.png",
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

