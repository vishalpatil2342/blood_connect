import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0), // Increased padding for a cleaner look
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${FirebaseAuth.instance.currentUser?.email?.split('@')[0] ?? 'User'}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey[800],
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFFE60000)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Thane, Maharashtra',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE60000), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE60000).withValues(alpha: 0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.person_rounded, color: Color(0xFFE60000), size: 30),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),
            
            // Stats / Quick Action Cards
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.search_rounded,
                    title: 'Find\nDonors',
                    backgroundColor: Colors.blue.shade50,
                    iconColor: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.bloodtype_rounded,
                    title: 'Donate\nBlood',
                    backgroundColor: const Color(0xFFFFF0F5),
                    iconColor: const Color(0xFFE60000),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 36),
            
            // Urgent Requests Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Urgent Requests',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFE60000),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Urgent Request List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return _buildRequestCard();
              },
            ),
            
            // Extra spacing at the bottom so the floating nav bar doesn't cover content
            const SizedBox(height: 80), 
          ],
        ),
      ),
    );
  }

  /// Floating, deeply rounded action cards
  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(28), // Deep pill-like rounding
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.6),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 6), // Soft bottom shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Left aligned for modern look
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Colors.grey[800],
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  /// Smooth elevated request cards
  Widget _buildRequestCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Blood Group Indicator
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text(
                'O+',
                style: TextStyle(
                  color: Color(0xFFE60000),
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Request Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'City Hospital',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.opacity_rounded, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '2 Units needed',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '2 hours ago',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Pill-shaped Donate Button
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(80, 44),
              backgroundColor: const Color(0xFFE60000),
              elevation: 4,
              shadowColor: const Color(0xFFE60000).withValues(alpha: 0.4),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Pill shape
              ),
              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            child: const Text('Donate'),
          ),
        ],
      ),
    );
  }
}