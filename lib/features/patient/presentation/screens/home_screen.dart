import 'package:flutter/material.dart';
import 'package:blood_connect/features/patient/presentation/screens/home_tab.dart';
import 'package:blood_connect/features/patient/presentation/screens/profile_screen.dart';
import 'package:blood_connect/features/patient/presentation/screens/blood_banks_screen.dart';
import 'package:blood_connect/features/patient/presentation/screens/activity_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // The 4 main screens for the navigation tabs
  final List<Widget> _screens = [
    const HomeTab(),
    const BloodBanksScreen(),
    const ActivityScreen(), // Replaced placeholder
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildStickyNavBar(),
    );
  }

  Widget _buildStickyNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, index: 0),
              _buildNavItem(icon: Icons.local_hospital_outlined, selectedIcon: Icons.local_hospital_rounded, index: 1),
              _buildNavItem(icon: Icons.show_chart_rounded, selectedIcon: Icons.show_chart_rounded, index: 2),
              _buildNavItem(icon: Icons.person_outline, selectedIcon: Icons.person_rounded, index: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required IconData selectedIcon, required int index}) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? const Color(0xFFFF2A5F) : Colors.grey.shade400,
              size: 26,
            ),
            const SizedBox(height: 4),
            // The small indicator dot
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFF2A5F) : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}