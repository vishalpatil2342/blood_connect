import 'dart:async';
import 'package:blood_connect/features/patient/presentation/screens/home_screen.dart';
import 'package:blood_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_connect/features/auth/presentation/screens/register_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _timerCompleted = false;

  @override
  void initState() {
    super.initState();
    
    // Start the 2-second minimum delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _timerCompleted = true;
        });
        _navigateIfReady(); // Check if auth is already loaded
      }
    });
  }

  void _navigateIfReady() {
    // 1. Block navigation if the 2 seconds haven't passed yet
    if (!_timerCompleted) return;

    final authState = ref.read(authStateProvider);
    
    // 2. Block navigation if Firebase is still loading
    if (authState.isLoading) return;

    // 3. Both conditions are met; safe to navigate
    authState.whenData((user) {
      if (user != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes
    ref.listen(authStateProvider, (previous, next) {
      if (!next.isLoading) {
         _navigateIfReady(); // Check if timer is already done
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