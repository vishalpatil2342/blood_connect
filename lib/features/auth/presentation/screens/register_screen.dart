// ==========================================
// 2. REGISTER SCREEN
// ==========================================
import 'package:blood_connect/features/auth/presentation/screens/signin_screen.dart';
import 'package:blood_connect/features/patient/presentation/screens/home_screen.dart';
import 'package:blood_connect/features/auth/presentation/screens/phone_login_screen.dart';
import 'package:blood_connect/shared/widgets/custom_text_field.dart';
import 'package:blood_connect/shared/widgets/red_background_clipper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_connect/features/auth/presentation/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  bool _acceptTerms = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController bloodTypeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    cityController.dispose();
    bloodTypeController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please accept the terms and conditions")),
      );
      return;
    }

    await ref.read(authControllerProvider.notifier).signUp(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          name: nameController.text.trim(),
          location: cityController.text.trim(),
          bloodType: bloodTypeController.text.trim(),
        );

    if (!mounted) return;

    final state = ref.read(authControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error.toString())),
      );
    } else if (!state.isLoading) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }


  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. The Red Curved Background
          ClipPath(
            clipper: RedBackgroundClipper(),
            child: Container(
              height: size.height * 0.55, 
              color: const Color(0xFFff1818), // Your app's primary red
            ),
          ),
          
          // 2. The Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Register Account',
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Changed to white to show on red background
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Your Few Drops Can Be Someone's Else Ocean of Hope",
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  
                  // 3. The White Form Container (matches the image's floating card look)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          controller: nameController,
                          hint: 'Emmanuel Priestl',
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: emailController,
                          hint: 'Email Address',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: cityController,
                          hint: 'City / Location',
                          prefixIcon: Icons.location_on_outlined,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: bloodTypeController,
                          hint: 'Blood Type (e.g. O+)',
                          prefixIcon: Icons.water_drop_outlined,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: passwordController,
                          hint: 'Create Password',
                          isPassword: true,
                          prefixIcon: Icons.lock_outline,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Checkbox(
                              value: _acceptTerms,
                              activeColor: const Color(0xFFE60000),
                              onChanged: (value) {
                                setState(() {
                                  _acceptTerms = value ?? false;
                                });
                              },
                            ),
                            Expanded(
                              child: Text(
                                'By Creating account, you are accepting terms & conditions',
                                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            if (_acceptTerms) {
                              registerUser();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Accept Terms First")),
                              );
                            }
                          },
                          child: const Text('Register'),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an accout? ',
                        style: TextStyle(color: Colors.grey[800], fontSize: 13),
                        children: [
                          TextSpan(
                            text: 'Sign in',
                            style: const TextStyle(
                              color: Color(0xFFE60000),
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignInScreen(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  
                  // Phone Number Login Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey[300]!),
                      minimumSize: const Size(double.infinity, 50), // Match width of other elements if desired
                    ),
                    icon: const Icon(Icons.phone_android, size: 24, color: Color(0xFFff1818)),
                    label: const Text("Sign up with Phone Number"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PhoneLoginScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

