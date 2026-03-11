import 'package:blood_connect/features/patient/presentation/providers/data_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_connect/core/models/notification_model.dart';
import 'package:blood_connect/core/models/donation_model.dart';
import 'package:blood_connect/features/patient/data/repositories/notification_repository.dart';
import 'package:blood_connect/features/patient/data/repositories/donation_repository.dart';
import 'package:blood_connect/core/services/push_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:blood_connect/core/models/blood_request_model.dart';
import 'package:blood_connect/features/patient/presentation/screens/notifications_screen.dart';
import 'package:blood_connect/features/patient/presentation/screens/find_donors_screen.dart';
import 'package:blood_connect/features/patient/presentation/screens/create_request_screen.dart';
import 'package:blood_connect/core/utils/blood_compatibility.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Removed SafeArea from the very top so the red header can go behind the status bar
    return SingleChildScrollView(
      // Padding is removed from here so the top red container can be full width
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. New Red Header Section
          _buildRedHeader(context, ref),
          
          // 2. The Rest of the Content (Wrapped in padding to maintain margins)
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats / Quick Action Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        icon: Icons.search_rounded,
                        title: 'Find\nDonors',
                        backgroundColor: Colors.blue.shade50,
                        iconColor: Colors.blue.shade700,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FindDonorsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        icon: Icons.bloodtype_rounded,
                        title: 'Book\nRequest', // Updated text to match your image somewhat
                        backgroundColor: const Color(0xFFFFF0F5),
                        iconColor: const Color(0xFFE60000),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateRequestScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),

                // Blood Groups Categories
                const Text(
                  'Blood Groups',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Horizontal List of Blood Groups
                SizedBox(
                  height: 90,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const AlwaysScrollableScrollPhysics(), // Ensures horizontal scroll isn't blocked by the vertical scroll
                    padding: const EdgeInsets.only(bottom: 8), 
                    // To show shadow naturally without being clipped
                    clipBehavior: Clip.none,
                    children: [
                      _buildBloodGroupItem('A+', fillPercentage: 0.8),
                      _buildBloodGroupItem('B+', fillPercentage: 0.4),
                      _buildBloodGroupItem('AB+', fillPercentage: 1.0),
                      _buildBloodGroupItem('O+', fillPercentage: 0.2),
                      _buildBloodGroupItem('A-', fillPercentage: 0.6),
                      _buildBloodGroupItem('B-', fillPercentage: 0.5),
                      _buildBloodGroupItem('AB-', fillPercentage: 0.9),
                      _buildBloodGroupItem('O-', fillPercentage: 0.1),
                    ],
                  ),
                ),

              ],
            ),
          ),
          
          // Emergency Requests Section with White Background
          Container(
            color: Colors.white, // White Background
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Urgent Requests Header
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Emergency Blood Requests',
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: Colors.black87, // Dark text for contrast
                      ),
                    ),
                    Icon(Icons.warning_amber_rounded, color: Color(0xFFE60000)), // Red Icon
                  ],
                ),
                const SizedBox(height: 16),
                
                // Urgent Request List
                ref.watch(emergencyRequestsProvider).when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(color: Color(0xFFE60000)),
                    ),
                  ),
                  error: (error, stack) => const Center(
                    child: Text('Error loading requests', style: TextStyle(color: Colors.black87)),
                  ),
                  data: (requests) {
                    if (requests.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text("No emergency requests yet.", style: TextStyle(color: Colors.black87)),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero, 
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: requests.length > 10 ? 10 : requests.length,
                      itemBuilder: (context, index) {
                        return _buildRequestCard(context, ref, requests[index]);
                      },
                    );
                  },
                ),
                
                // Extra spacing at the bottom so the floating nav bar doesn't cover content
                const SizedBox(height: 80), 
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The new top red area matching your image
  Widget _buildRedHeader(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final userName = userAsync.when(
      data: (user) {
        if (user == null || user.name.trim().isEmpty) {
          return 'User';
        }
        return user.name;
      },
      loading: () => '...',
      error: (_, __) => 'User',
    );
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        // Add dynamic top padding so the text doesn't hide behind the phone's status bar clock/battery
        top: MediaQuery.of(context).padding.top + 20, 
        left: 24,
        right: 24,
        bottom: 30,
      ),
      decoration: const BoxDecoration(
        // Added a slight gradient to make it look premium like the image
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF4D4D), // Lighter red
            Color(0xFFE60000), // Primary red
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hello, $userName',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              // Notification Bell Icon with slight translucent background
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_active, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Let's make a difference together!",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Your Blood Saves Lives!",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Floating, deeply rounded action cards
  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color backgroundColor,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(28), 
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.6),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 6), 
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
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
      ),
    );
  }

  // Helper to calculate "Time Ago"
  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) return '${difference.inDays} days ago';
    if (difference.inHours > 0) return '${difference.inHours} hours ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes} mins ago';
    return 'Just now';
  }

  /// Smooth elevated request cards
  Widget _buildRequestCard(BuildContext context, WidgetRef ref, BloodRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      // ... existing UI
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name', style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(request.patientName, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 16),
                    Text('Location', style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(request.hospital, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 16)),
                  ],
                ),
              ),
              // Droplet
              Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.water_drop, size: 64, color: Color(0xFFFF2A5F)),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(request.bloodType, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_getTimeAgo(request.createdAt), style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w600)),
              GestureDetector(
                onTap: () {
                  final userAsync = ref.read(userProfileProvider);
                  userAsync.whenData((currentUser) {
                    if (currentUser == null) return;
                    
                    final isCompatible = BloodCompatibility.canDonate(
                      donorBloodType: currentUser.bloodType,
                      receiverBloodType: request.bloodType,
                    );

                    if (isCompatible) {
                      final pushService = ref.read(pushNotificationServiceProvider);
                      final notificationRepo = ref.read(notificationRepositoryProvider);
                      final donationRepo = ref.read(donationRepositoryProvider);

                      // In-app immediate alert for the donor
                      pushService.showInAppNotification(
                        title: 'Donation Accepted',
                        body: 'You successfully signed up to donate ${request.bloodType} blood!',
                      );

                      // Save inbox notification for the receiver
                      notificationRepo.createNotification(
                        NotificationModel(
                          id: '', // Firestore auto-generates ID
                          userId: request.requesterId,
                          title: 'Donor Found!',
                          message: '${currentUser.name} has accepted your request for ${request.bloodType} blood.',
                          isRead: false,
                          createdAt: DateTime.now(),
                        ),
                      );

                      // Save the donation transaction
                      donationRepo.createDonation(
                        Donation(
                          id: '', // Firestore auto ID
                          donorId: currentUser.uid,
                          requestId: request.id,
                          hospital: request.hospital,
                          bloodType: request.bloodType,
                          donationDate: DateTime.now(),
                          status: 'pending',
                        ),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Thank you! You are compatible. Request accepted.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sorry, your blood type (${currentUser.bloodType}) is not compatible with ${request.bloodType}.'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  });
                },
                child: const Text(
                  'Donate',
                  style: TextStyle(
                    color: Color(0xFFFF2A5F), 
                    fontWeight: FontWeight.w900, 
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Reusable Blood Group Item
  Widget _buildBloodGroupItem(String type, {double fillPercentage = 1.0}) {
    return Container(
      width: 90, // Match the height of 90 defined in the SizedBox above it to make it perfectly square
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Slightly less rounded so it screams "square shape"
        border: Border.all(
          color: const Color(0xFFFF2A5F).withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {}, // Ready for state management filter changes
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PartiallyFilledBloodDrop(
                fillPercentage: fillPercentage,
                color: const Color(0xFFFF2A5F),
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                type,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PartiallyFilledBloodDrop extends StatelessWidget {
  final double fillPercentage;
  final Color color;
  final double size;

  const _PartiallyFilledBloodDrop({
    required this.fillPercentage,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outline
        Icon(Icons.water_drop_outlined, color: color, size: size),
        // Filled portion
        ClipRect(
          clipper: _BottomFillClipper(fillPercentage),
          child: Icon(Icons.water_drop, color: color, size: size),
        ),
      ],
    );
  }
}

class _BottomFillClipper extends CustomClipper<Rect> {
  final double fillPercentage;

  _BottomFillClipper(this.fillPercentage);

  @override
  Rect getClip(Size size) {
    // fillPercentage = 1.0 means fully filled (top is 0)
    // fillPercentage = 0.0 means fully empty (top is height)
    final top = size.height * (1 - fillPercentage);
    return Rect.fromLTRB(0, top, size.width, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => true;
}
