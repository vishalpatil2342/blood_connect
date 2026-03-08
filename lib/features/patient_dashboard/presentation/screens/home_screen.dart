import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'request_blood_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const RequestBloodScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      // We use a custom Container instead of BottomNavigationBar for full design control
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          // A subtle shadow pointing upwards to separate the fixed bar from the body
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.15),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, -4), 
            ),
          ],
        ),
        // SafeArea ensures the icons don't get hidden under iOS swipe bars or Android nav buttons
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(icon: Icons.home_rounded, index: 0),
                _buildNavItem(icon: Icons.add_circle_rounded, index: 1),
                _buildNavItem(icon: Icons.person_rounded, index: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Custom widget for each navigation icon
  Widget _buildNavItem({required IconData icon, required int index}) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      // Keeps the background transparent but gives a nice, clickable area
      behavior: HitTestBehavior.opaque, 
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF0F5) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? const Color(0xFFE60000) : Colors.grey[400],
          size: 28,
        ),
      ),
    );
  }
}