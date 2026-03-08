import 'dart:async';
import 'package:flutter/material.dart';
import 'package:blood_connect/features/auth/presentation/screens/register_screen.dart';

// ==========================================
// 1. WELCOME / SPLASH SCREEN
// ==========================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RegisterScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Image.asset(
          "assets/images/splash_logo.png",
          fit: BoxFit.cover, // makes image full screen
        ),
      ),
    );
  }
}
